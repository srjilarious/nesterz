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

    fn parseInstruction(self: *Self, instTok: Token) !Instruction {
        const op = nes.emu.cpuOpFromStr(instTok.value.string);
        if (op == null) {
            // TODO: Handle errors with values here.
            return error.UnknownOp;
        }

        const t1 = self.tokenIt.next();
        if (t1 == null or t1.?.type == .NewLine or t1.?.type == .Eof) {
            // No operand, just the instruction.
            return Instruction{
                .op = op.?,
                .addrMode = AddressMode.Implied,
                .operand = null,
            };
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
                    const inst = try self.parseInstruction(t1.?);
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
                        const inst = try self.parseInstruction(t1.?);
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
