const std = @import("std");
const nes = @import("nesterz");
const testz = @import("testz");

const CpuOp = nes.CpuOp;
const AddressMode = nes.AddressMode;
const Instruction6502 = nes.emu.Instruction6502;

pub fn checkBasicFunctions() !void {
    try testz.expectTrue(nes.emu.isStore(CpuOp.STA));
    try testz.expectFalse(nes.emu.isStore(CpuOp.LDA));

    const inst = try Instruction6502.fromOpCode(0x69);
    try testz.expectEqual(inst.opCode, 0x69);
    try testz.expectEqual(inst.op, .ADC);
    try testz.expectEqual(inst.mode, .Immediate);
    try testz.expectEqual(inst.numCycles, 2);
    try testz.expectEqual(inst.numBytes, 2);
}
