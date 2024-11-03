// zig fmt: off
const std = @import("std");
const nes = @import("nesterz");
const structs = @import("./structs.zig");
const utils = @import("./utils.zig");

const CpuOp = nes.CpuOp;
const AddressMode = nes.AddressMode;

const Operand = structs.Operand;
const Instruction = structs.Instruction;
const InstructionBytes = structs.InstructionBytes;
const Label = structs.Label;
const AssemblyLine = structs.AssemblyLine;
const AssemblyError = structs.AssemblyError;
const AssemblyParseError = structs.AssemblyParseError;

const AddrOp = struct {
    addr: AddressMode,
    operand: ?Operand
};

pub fn parseOperand(opStr: []const u8) !Operand {
    // Should not get a zero length string.
    std.debug.assert(opStr.len != 0);

    switch(opStr[0])
    {
        '$' => {
            const parsed = try std.fmt.parseInt(u16, opStr[1..], 16);
            switch(parsed) {
                0...0xff => {
                    return .{ .byte = @as(u8, @truncate(parsed)) };
                },
                else => {
                    return .{ .word = parsed };
                }
            }
        },
        'a'...'z', 'A'...'Z' => {
            // Handle symbol.
        },
        else => {
            const parsed = try std.fmt.parseInt(i32, opStr, 10);
            const val = @as(u32, @bitCast(parsed));
            switch(parsed) {
                -32768...-129 => {
                    return .{ .word = @as(u16, @truncate(val))};
                },
                -128...-1 => {
                    return .{ .byte = @as(u8, @truncate(val))};
                },
                0...0xff => {
                    return .{ .byte = @as(u8, @truncate(val)) };
                },
                0x100...65535 => return .{ .word = @as(u16, @truncate(val)) },
                else => return error.OperandTooBig,
            }
        }
    }
    return error.NoIdea;
}

pub const Assembler6502 = struct {
    alloc: std.mem.Allocator,
    labels: std.ArrayList(Label),
    symbols: std.StringHashMap(Operand),
    lines: std.ArrayList(AssemblyLine),
    currLineNo: usize,
    currByteOffset: usize,
    // instMap: InstructionMap,
    
    pub fn init(alloc: std.mem.Allocator) !Assembler6502 {
        return .{
            .alloc = alloc,
            .labels = std.ArrayList(Label).init(alloc),
            .symbols = std.StringHashMap(Operand).init(alloc),
            .lines = std.ArrayList(AssemblyLine).init(alloc),
            .currLineNo = 0,
            .currByteOffset = 0
        };
    }

    pub fn deinit(self: *Assembler6502) void {
        // TODO: implement
        self.labels.deinit();
        self.symbols.deinit();
        self.lines.deinit();
    }

    // fn parseOperand()
    fn parseAddrAndOperand(_: *Assembler6502, op: CpuOp, tokens: std.mem.TokenIterator(u8, .any)) !?AddrOp {
        const s = tokens.next();
        if(s == null) {
            return .{
                .addr = .Implied,
                .operand = null
            };
        }

        if(nes.isRelativeBranch(op)) {
            //self.parseOperand(s.?);
        }
    }

    pub fn parseLine(self: *Assembler6502, line: []const u8) !?AssemblyLine {
        const commentRemovedLine = utils.removeComment(line);
        var tokens = std.mem.tokenizeAny(u8, commentRemovedLine, " \t");
        
        const cmdTok = tokens.next();
        if(cmdTok == null) return null;

        if(std.ascii.eqlIgnoreCase("define", cmdTok.?)) {
            std.debug.print("{}: Got define!\n", .{self.currLineNo});
        }

        const op = nes.emu.cpuOpFromStr(cmdTok.?);
        if(op == null) {
            std.debug.print("{}: ERROR: Got bad instruction: {s}\n", .{self.currLineNo, cmdTok.?});
        }

        return AssemblyLine{
            .instr = .{ .op = op.?, .addrMode = AddressMode.Implied, .operand = null },
            .label = null,
            .comment = null,
            .lineNo = self.currLineNo
        };
    }
};
