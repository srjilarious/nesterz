const std = @import("std");
const nes = @import("nesterz");

test "AND immediate test." {
    var cpu = nes.Cpu6502.init();
    cpu.procState = nes.CpuState.Normal;
    cpu.a = 0x30;
    cpu.currInst = nes.Instruction.init(0x29, nes.CpuOp.AND, nes.AddressMode.Immediate, 2, 2);
    cpu.dataBus = 0x29;
    try cpu.tick();
    cpu.dataBus = 0x1a;
    try cpu.tick();
    try std.testing.expectEqual(cpu.a, 0x10);
}
