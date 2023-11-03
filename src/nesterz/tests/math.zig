const std = @import("std");
const nes = @import("nesterz");

test "AND immediate test." {
    std.debug.print("math test!\n", .{});
    var cpu = nes.Cpu6502.init();
    cpu.currInst = nes.Instruction.init(0x29, nes.CpuOp.AND, nes.AddressMode.Immediate, 2, 2);
}
