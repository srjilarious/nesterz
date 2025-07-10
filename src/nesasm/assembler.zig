// zig fmt: off
const std = @import("std");
const nes = @import("nesterz");
const structs = @import("./structs.zig");
const utils = @import("./utils.zig");

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

const AddrOp = struct {
    addr: AddressMode,
    operand: ?Operand
};

const NumCpuOps = @typeInfo(CpuOp).@"enum".fields.len;
const NumAddressModes = @typeInfo(AddressMode).@"enum".fields.len;
pub fn createOpCodeTable() [NumCpuOps][NumAddressModes]?Instruction6502 {
    var opCodeTable : [NumCpuOps][NumAddressModes]?Instruction6502 = [_][NumAddressModes]?Instruction6502{ [_]?Instruction6502{null} ** NumAddressModes } ** NumCpuOps;

    for(0..0xff) |val| {
        if(Instruction6502.fromOpCode(val)) |inst| {
            opCodeTable[@intFromEnum(inst.op)][@intFromEnum(inst.mode)] = inst;
        } else |_| {}
    }
    return opCodeTable;
}

pub const OpCodeTable = createOpCodeTable();
pub fn getInstFromOp(op: CpuOp, mode: AddressMode) ?Instruction6502 {
    return OpCodeTable[@intFromEnum(op)][@intFromEnum(mode)];
}

pub fn codeGen(op:CpuOp, addrOp: AddrOp, buff: *[4]u8) ?[]u8 {
    const inst = getInstFromOp(op, addrOp.addr);
    if(inst == null) return null;

    // var buffv = &buff;
    switch(addrOp.addr) {
        .Implied, .Accumulator => {
            if(addrOp.operand != null) {
                // TODO: Add in error handling w/ messages..
                return null;
            }
            buff.* = .{ inst.?.opCode, 0, 0, 0};
            return buff[0..1];
        },
        .Immediate, .ZeroPage, .ZeroPageX, .ZeroPageY, .Relative => {
            // Must have an operand to be valid.
            if(addrOp.operand == null) {
                // TODO: Add in error handling w/ messages..
                return null;
            }
            
            switch(addrOp.operand.?) {
                .byte => |b| {
                    buff.* = .{ inst.?.opCode, b, 0, 0 };
                    return buff[0..2];
                },
                .word => {
                    // Immediates must be bytes.
                    return null;
                }
            }
        },
        .Absolute => {
            // Must have an operand to be valid.
            if(addrOp.operand == null) {
                // TODO: Add in error handling w/ messages..
                return null;
            }
            
            switch(addrOp.operand.?) {
                .byte => {
                    // Values must be words.
                    return null;
                },
                .word => |w| {
                    buff.* = .{ inst.?.opCode, @intCast(w & 0xff), @intCast(w >> 8), 0 };
                    return buff[0..3];
                }
            }

        },
        else => { @panic("Not implemented yet!"); }
    }
}


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

pub fn parseAddrAndOperand(op: CpuOp, tokens: *std.mem.TokenIterator(u8, .any)) !?AddrOp {
    const s = tokens.next();
    if(s == null) {
        return .{
            .addr = .Implied,
            .operand = null
        };
    }

    std.debug.assert(s.?.len != 0);
    const operand = s.?;

    if(nes.isRelativeBranch(op)) {
        //self.parseOperand(s.?);
    }
    else {
        // Handle immediate mode.
        if(operand[0] == '#') {
            return .{ .addr = .Immediate, .operand = try parseOperand(operand[1..]) };
        }
        else if(operand.len == 1 and operand[0] == 'A') {
            return .{ .addr = .Accumulator, .operand = null };
        }
        else if(std.ascii.endsWithIgnoreCase(operand, ",X)")) {
            return .{ .addr = .IndirectX, .operand = try parseOperand(operand[1..operand.len-3]) };
        }
        else if(std.ascii.endsWithIgnoreCase(operand, "),Y")) {
            return .{ .addr = .IndirectY, .operand = try parseOperand(operand[1..operand.len-3]) };
        }
        else if(std.ascii.endsWithIgnoreCase(operand, ")")) {
            return .{ .addr = .Indirect, .operand = try parseOperand(operand[1..operand.len-1]) };
        }
        else if(std.ascii.endsWithIgnoreCase(operand, ",X")) {
            const val = try parseOperand(operand[0..operand.len-2]);
            switch(val) {
                .byte => |_| {
                    return .{ .addr = .ZeroPageX, .operand = val};
                },
                .word => |_| {
                    return .{ .addr = .AbsoluteX, .operand = val};
                }
            }
        }
        else if(std.ascii.endsWithIgnoreCase(operand, ",Y")) {
            const val = try parseOperand(operand[0..operand.len-2]);
            switch(val) {
                .byte => |_| {
                    return .{ .addr = .ZeroPageY, .operand = val};
                },
                .word => |_| {
                    return .{ .addr = .AbsoluteY, .operand = val};
                }
            }
        } 
        else {
            const val = try parseOperand(operand);
            switch(val) {
                .byte => |_| {
                    return .{ .addr = .ZeroPage, .operand = val};
                },
                .word => |_| {
                    return .{ .addr = .Absolute, .operand = val};
                }
            }
        }
    }

    return error.UnexpectedError;
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
