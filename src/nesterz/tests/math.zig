const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");

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

test "AND test 2" {
    var tn = try fix.TestNes.initWithTesData(&std.testing.allocator, &[_]u8{
        0x29, 0x1a, // AND 0x1a
    });
    tn.printDebug = true;
    defer tn.deinit();
    tn.cpu.a = 0x30;

    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x10);
}
