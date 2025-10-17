// 6502 Assembler using Scanner
const std = @import("std");
const nes = @import("nesterz");
const structs = @import("./structs.zig");
const utils = @import("./utils.zig");
const scanner = @import("./scanner.zig");
const Token = scanner.Token;
const TokenIterator = scanner.TokenIterator;
const TokenType = scanner.TokenType;

const CpuOp = nes.CpuOp;
const AddressMode = nes.AddressMode;
const Instruction6502 = nes.Instruction;

const Operand = structs.Operand;
const Instruction = structs.Instruction;
const InstructionBytes = structs.InstructionBytes;
const Label = structs.Label;
const AssemblyLine = structs.AssemblyLine;
const AssemblyError = structs.AssemblyError;
const AssemblyParseError = structs.AssemblyParseError;

pub const Assembler6502 = struct {
    alloc: std.mem.Allocator,
    labels: std.ArrayList(Label),
    source: []const u8,
    scanner: *scanner.Scanner,
    tokenIt: scanner.TokenIterator,
    symbols: std.StringHashMap(Operand),
    lines: std.ArrayList(AssemblyLine),
    currLineNo: usize,
    currByteOffset: usize,
    // instMap: InstructionMap,

    const Self = @This();

    pub fn init(alloc: std.mem.Allocator, source: []const u8) !Assembler6502 {
        const scan = try alloc.create(scanner.Scanner);
        scan.* = scanner.Scanner.init(alloc, source);
        _ = scan.scan();

        return .{
            .alloc = alloc,
            .source = source,
            .labels = std.ArrayList(Label).init(alloc),
            .symbols = std.StringHashMap(Operand).init(alloc),
            .lines = std.ArrayList(AssemblyLine).init(alloc),
            .currLineNo = 0,
            .currByteOffset = 0,
            .scanner = scan,
            .tokenIt = scan.iterator(),
        };
    }

    pub fn deinit(self: *Assembler6502) void {
        self.scanner.deinit();
        self.labels.deinit();
        self.symbols.deinit();
        self.lines.deinit();
    }

    pub fn isEof(self: *Self) bool {
        return self.tokenIt.isEof();
    }

    fn getOperandValue(self: *Self, tok: Token) !Operand {
        switch (tok.type) {
            .Number => {
                const value = tok.value.number;
                if (value <= 255) {
                    return Operand{ .byte = @intCast(value) };
                } else {
                    return Operand{ .word = @intCast(value) };
                }
            },
            .Identifier => {
                const sym = self.symbols.get(tok.value.string);
                if (sym) |s| {
                    return s;
                } else {
                    return error.UnknownSymbol;
                }
            },
            else => {
                // Invalid token type for operand, return zero operand for now.
                return error.InvalidOperandToken;
            },
        }
    }

    fn parseInstruction(self: *Self, instTok: Token, t1: ?Token) !Instruction {
        const op = nes.emu.cpuOpFromStr(instTok.value.string);
        if (op == null) {
            // TODO: Handle errors with values here.
            return error.UnknownOp;
        }

        //const t1 = self.tokenIt.next();
        if (t1 == null or t1.?.type == .NewLine or t1.?.type == .Eof) {
            // No operand, just the instruction.
            return Instruction{
                .op = op.?,
                .addrMode = .Implied,
                .operand = null,
            };
        }

        switch (t1.?.type) {
            .Number => {
                // Zero Page or Absolute addressing.
                const value = t1.?.value.number;
                if (value <= 255) {
                    const t2 = self.tokenIt.peek();
                    if (t2 == null or t2.?.type == .NewLine or t2.?.type == .Eof) {
                        // Zero Page addressing.
                        return Instruction{
                            .op = op.?,
                            .addrMode = .ZeroPage,
                            .operand = Operand{ .byte = @intCast(value) },
                        };
                    } else if (t2.?.type == .Comma) {
                        _ = self.tokenIt.next(); // Consume the comma.
                        const nextTok = self.tokenIt.next();
                        if (nextTok == null or nextTok.?.type != .Identifier) {
                            return error.MissingAddressModeValue;
                        }

                        if (std.ascii.eqlIgnoreCase(nextTok.?.value.string, "X")) {
                            return Instruction{
                                .op = op.?,
                                .addrMode = .ZeroPageX,
                                .operand = Operand{ .byte = @intCast(value) },
                            };
                        }
                        if (std.ascii.eqlIgnoreCase(nextTok.?.value.string, "Y")) {
                            return Instruction{
                                .op = op.?,
                                .addrMode = .ZeroPageY,
                                .operand = Operand{ .byte = @intCast(value) },
                            };
                        } else {
                            return error.InvalidAddressMode; // Invalid address mode.
                        }
                    } else {
                        return error.UnexpectedTokenType; // Unexpected token type.
                    }
                } else {
                    const t2 = self.tokenIt.peek();
                    if (t2 == null or t2.?.type == .NewLine or t2.?.type == .Eof) {
                        // Zero Page addressing.
                        return Instruction{
                            .op = op.?,
                            .addrMode = .Absolute,
                            .operand = Operand{ .word = @intCast(value) },
                        };
                    } else if (t2.?.type == .Comma) {
                        _ = self.tokenIt.next(); // Consume the comma.
                        const nextTok = self.tokenIt.next();
                        if (nextTok == null or nextTok.?.type != .Identifier) {
                            return error.MissingAddressModeValue;
                        }

                        if (std.ascii.eqlIgnoreCase(nextTok.?.value.string, "X")) {
                            return Instruction{
                                .op = op.?,
                                .addrMode = .AbsoluteX,
                                .operand = Operand{ .word = @intCast(value) },
                            };
                        }
                        if (std.ascii.eqlIgnoreCase(nextTok.?.value.string, "Y")) {
                            return Instruction{
                                .op = op.?,
                                .addrMode = .AbsoluteY,
                                .operand = Operand{ .word = @intCast(value) },
                            };
                        } else {
                            return error.InvalidAddressMode; // Invalid address mode.
                        }
                    } else {
                        return error.UnexpectedTokenType; // Unexpected token type.
                    }
                }
            },
            .Pound => {
                // Immediate value with pound sign.
                const nextTok = self.tokenIt.next();
                if (nextTok == null or nextTok.?.type != .Number) {
                    return error.MissingImmediateValue;
                }
                const value = nextTok.?.value.number;
                if (value > 255) {
                    return error.OperandTooBig; // Handle operand size limit.
                }
                return Instruction{
                    .op = op.?,
                    .addrMode = .Immediate,
                    .operand = Operand{ .byte = @intCast(value) },
                };
            },
            // Handle indirect addressing modes.
            .LeftParen => {
                // Need to grab the indirect value.
                const valueTok = self.tokenIt.next();
                if (valueTok == null or valueTok.?.type == .NewLine or valueTok.?.type == .Eof) {
                    return error.MissingIndirectValue;
                }

                // We expect a value or an identifier here.
                if (valueTok.?.type != .Number and valueTok.?.type != .Identifier) {
                    return error.InvalidIndirectValue;
                }

                const t2 = self.tokenIt.next();
                if (t2 == null or t2.?.type == .NewLine or t2.?.type == .Eof) {
                    return error.MissingIndirectParam;
                }

                const operand = try self.getOperandValue(valueTok.?);

                // Check for indirect addressing mode.
                if (t2.?.type == .RightParen) {
                    return .{
                        .op = op.?,
                        .addrMode = .Indirect,
                        .operand = operand,
                    };
                }
            },
            .Identifier => {
                // Check for an accumulator instruction.
                if (std.ascii.eqlIgnoreCase(t1.?.value.string, "A")) {
                    return Instruction{
                        .op = op.?,
                        .addrMode = .Accumulator,
                        .operand = null,
                    };
                }
            },
            else => {
                // TODO: Handle other address modes...
                return error.InvalidAddressMode; // TODO: Implement other modes.
            },
        }

        return error.NotImplemented; // TODO: Handle operands.
        // return Instruction{
        //     .op = op,
        //     .addrMode = addrMode,
        //     .operand = operand,
        // };
    }

    pub fn parseNextLine(self: *Self) !?AssemblyLine {
        const t1 = self.tokenIt.next();
        if (t1 == null or t1.?.type == .Eof) return null;

        if (t1.?.type == .NewLine) {
            self.currLineNo += 1;
            return null; // Skip empty lines
        }

        switch (t1.?.type) {
            .Identifier => {
                const t2 = self.tokenIt.next();

                // Handle standalone instruction.
                if (t2 == null or t2.?.type == .NewLine or t2.?.type == .Eof) {
                    const inst = try self.parseInstruction(t1.?, null);
                    return .{
                        .instr = inst,
                        .label = null,
                        .comment = null,
                        .lineNo = self.currLineNo,
                    };
                }

                switch (t2.?.type) {
                    .Colon => {
                        return error.NotImplemented;
                        // Handle label definition.
                        // const labelName = t1.?.value.string;
                        // const label = try Label.init(labelName, self.currLineNo, self.currByteOffset, self.alloc);
                        // try self.labels.append(label);

                        // const t3 = self.tokenIt.next(); // Consume the colon token.
                        // if (t2 == null or t2.?.type == .NewLine or t2.?.type == .Eof) {
                        //     return .{
                        //         .instr = null,
                        //         .label = label,
                        //         .comment = null,
                        //         .lineNo = self.currLineNo,
                        //     };
                        // }

                        // // If there's more tokens, we expect an instruction.
                        // const inst = try self.parseInstruction(t3.?);
                        // return .{
                        //     .instr = inst,
                        //     .label = label,
                        //     .comment = null,
                        //     .lineNo = self.currLineNo,
                        // };
                    },
                    .Equal => {
                        return error.NotImplemented;
                        // Handle symbol definition.
                        // const symbolName = cmdTok.value.string;
                        // const nextTok = self.tokenIt.next();
                        // if (nextTok == null or nextTok.?.type != .Number) {
                        //     return error.MissingSymbolValue;
                        // }
                        // const value = nextTok.?.value.number;
                        // const operand = Operand{ .word = @intCast(value) };
                        // self.symbols.put(symbolName, operand) catch |err| {
                        //     return err;
                        // };
                        // return .{
                        //     .instr = null,
                        //     .label = null,
                        //     .comment = null,
                        //     .lineNo = self.currLineNo,
                        // };
                    },
                    .Number, .Pound, .LeftParen, .Identifier => {
                        // Handle instruction with operand.
                        const inst = try self.parseInstruction(t1.?, t2);
                        return .{
                            .instr = inst,
                            .label = null,
                            .comment = null,
                            .lineNo = self.currLineNo,
                        };
                    },
                    else => {
                        return error.UnexpectedTokenType;
                    },
                }
            },
            else => {
                return error.UnexpectedTokenType;
            },
        }
    }
};
