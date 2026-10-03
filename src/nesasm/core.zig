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

const AddrOp = struct { addr: AddressMode, operand: ?Operand };

const NumCpuOps = @typeInfo(CpuOp).@"enum".field_names.len;
const NumAddressModes = @typeInfo(AddressMode).@"enum".field_names.len;
pub fn createOpCodeTable() [NumCpuOps][NumAddressModes]?Instruction6502 {
    var opCodeTable: [NumCpuOps][NumAddressModes]?Instruction6502 = @splat(@splat(null));

    for (0..0xff) |val| {
        if (Instruction6502.fromOpCode(val)) |inst| {
            opCodeTable[@intFromEnum(inst.op)][@intFromEnum(inst.mode)] = inst;
        } else |_| {}
    }
    return opCodeTable;
}

pub const OpCodeTable = createOpCodeTable();
pub fn getInstFromOp(op: CpuOp, mode: AddressMode) ?Instruction6502 {
    return OpCodeTable[@intFromEnum(op)][@intFromEnum(mode)];
}

pub fn codeGen(op: CpuOp, addrOp: AddrOp, buff: *[4]u8) ?[]u8 {
    const inst = getInstFromOp(op, addrOp.addr);
    if (inst == null) return null;

    // var buffv = &buff;
    switch (addrOp.addr) {
        .Implied,
        .Accumulator,
        => {
            if (addrOp.operand != null) {
                // TODO: Add in error handling w/ messages..
                return null;
            }
            buff.* = .{ inst.?.opCode, 0, 0, 0 };
            return buff[0..1];
        },
        .Immediate,
        .ZeroPage,
        .ZeroPageX,
        .ZeroPageY,
        .Relative,
        .IndirectX,
        .IndirectY,
        => {
            // Must have an operand to be valid.
            if (addrOp.operand == null) {
                // TODO: Add in error handling w/ messages..
                return null;
            }

            switch (addrOp.operand.?) {
                .byte => |b| {
                    buff.* = .{ inst.?.opCode, b, 0, 0 };
                    return buff[0..2];
                },
                .word => {
                    // Immediates must be bytes.
                    return null;
                },
            }
        },
        .Absolute,
        .AbsoluteX,
        .AbsoluteY,
        .Indirect,
        => {
            // Must have an operand to be valid.
            if (addrOp.operand == null) {
                // TODO: Add in error handling w/ messages..
                return null;
            }

            switch (addrOp.operand.?) {
                .byte => {
                    // Values must be words.
                    return null;
                },
                .word => |w| {
                    buff.* = .{ inst.?.opCode, @intCast(w & 0xff), @intCast(w >> 8), 0 };
                    return buff[0..3];
                },
            }
        },
    }
}
