// zig fmt: off
const std = @import("std");
const nes = @import("nesterz");

const CpuOp = nesterz.CpuOp;
const AddressMode = nesterz.AddressMode;
pub const Operand = union(enum) { 
    byte: u8, 
    word: u16 
};

pub const Instruction = struct {
    op: CpuOp,
    addrMode: AddressMode,
    operand: ?Operand
};
