// A scanner for the assembler.

const std = @import("std");
const errors = @import("./errors.zig");

// zig fmt: off
pub const TokenType = enum {
    LeftParen, RightParen, Comma, Dot, Pound,
    Colon, Equal,
    Comment,

    Identifier, String, Number,

    // Keywords

    NewLine, Eof,
};
// zig fmt: on

pub const TokenValue = union(enum) {
    number: u16,
    string: []const u8,
    none: u0,
};

pub const Token = struct {
    type: TokenType,
    // text: ?[]const u8,
    value: TokenValue,
    line: u32,
};

pub const TokenIterator = struct {
    tokens: std.ArrayList(Token),
    curr: usize,

    pub fn init(tokens: std.ArrayList(Token)) TokenIterator {
        return .{ .tokens = tokens, .curr = 0 };
    }

    pub fn next(self: *TokenIterator) ?Token {
        if (self.curr >= self.tokens.items.len) return null;
        const token = self.tokens.items[self.curr];
        self.curr += 1;
        return token;
    }

    pub fn peek(self: *TokenIterator) ?Token {
        if (self.curr >= self.tokens.items.len) return null;
        return self.tokens.items[self.curr];
    }

    pub fn isEof(self: *TokenIterator) bool {
        return self.curr >= self.tokens.items.len or
            self.tokens.items[self.curr].type == .Eof;
    }
};

pub const Scanner = struct {
    source: []const u8,
    alloc: std.mem.Allocator,
    tokens: std.ArrayList(Token),
    start: u32,
    curr: u32,
    line: u32,

    pub fn init(alloc: std.mem.Allocator, source: []const u8) Scanner {
        return .{
            .source = source,
            .alloc = alloc,
            .tokens = std.ArrayList(Token).init(alloc),
            .start = 0,
            .curr = 0,
            .line = 0,
        };
    }

    pub fn deinit(self: *Scanner) void {
        self.tokens.deinit();
    }

    pub fn scan(self: *Scanner) std.ArrayList(Token) {
        while (!self.isAtEnd()) {
            self.start = self.curr;
            self.scanToken();
        }

        self.addToken(.Eof, .none);
        return self.tokens;
    }

    fn addToken(self: *Scanner, t: TokenType, value: TokenValue) void {
        self.tokens.append(.{
            .type = t,
            .value = value,
            .line = self.line,
        }) catch unreachable;
    }

    fn isAtEnd(self: *Scanner) bool {
        return self.curr >= self.source.len;
    }

    fn advance(self: *Scanner) u8 {
        const c = self.source[self.curr];
        self.curr += 1;
        return c;
    }

    fn peek(self: *Scanner) u8 {
        if (self.curr >= self.source.len - 1) return 0;

        return self.source[self.curr + 1];
    }

    fn match(self: *Scanner, expected: u8) bool {
        if (self.isAtEnd()) return false;
        if (self.source[self.curr] != expected) return false;
        self.curr += 1;
        return true;
    }

    fn scanNumberString(self: *Scanner) []const u8 {
        while (self.peek() >= '0' and self.peek() <= '9') {
            _ = self.advance();
        }
        _ = self.advance();
        return self.source[self.start..self.curr];
    }

    fn scanToken(self: *Scanner) void {
        const c = self.advance();
        switch (c) {
            // zig fmt: off
            '#' => {self.addToken(.Pound, .none); },
            '(' => { self.addToken(.LeftParen, .none); },
            ')' => { self.addToken(.RightParen, .none); },
            ',' => { self.addToken(.Comma, .none); },
            '.' => { self.addToken(.Dot, .none); },
            ':' => { self.addToken(.Colon, .none); },
            '=' => { self.addToken(.Equal, .none); },
            // zig fmt: on
            ';' => {
                // Consume comments.
                while (self.peek() != '\n' and !self.isAtEnd()) {
                    _ = self.advance();
                }
            },
            ' ', '\t' => {
                // Ignore in-line whitespace.
            },
            '\n' => {
                self.addToken(.NewLine, .none);
                self.line += 1;
            },
            'a'...'z', 'A'...'Z', '_' => {
                // Handle identifiers.
                while (self.peek() != 0 and (self.peek() >= 'a' and self.peek() <= 'z' or
                    self.peek() >= 'A' and self.peek() <= 'Z' or
                    self.peek() >= '0' and self.peek() <= '9' or
                    self.peek() == '_'))
                {
                    _ = self.advance();
                }
                _ = self.advance();
                const identifier = self.source[self.start..self.curr];
                self.addToken(.Identifier, .{ .string = identifier });
            },
            '0'...'9' => {
                // Handle numbers.
                const numStr = self.scanNumberString();
                if (std.fmt.parseInt(u16, numStr, 10)) |parsed| {
                    self.addToken(.Number, .{ .number = parsed });
                } else |_| {
                    errors.err(self.line, "Invalid number format");
                }
            },
            '$' => {
                _ = self.advance();

                // Handle numbers.
                const numStr = self.scanNumberString();
                if (std.fmt.parseInt(u16, numStr[1..], 16)) |parsed| {
                    self.addToken(.Number, .{ .number = parsed });
                } else |_| {
                    errors.err(self.line, "Invalid number format");
                }
            },
            else => {
                errors.err(self.line, "Unexpected character");
            },
        }
    }

    pub fn iterator(self: *Scanner) TokenIterator {
        return TokenIterator.init(self.tokens);
    }
};
