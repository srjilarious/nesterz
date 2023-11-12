const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");

const CpuFlags = nes.CpuFlags;

test "LSR Accumulator" {
    var tn = try fix.TestNes.initWithTesData(&std.testing.allocator, &[_]u8{
        0x4A, // LSR A
        0x4A, // LSR A
        0x4A, // LSR A
        0x4A, // LSR A
    });
    defer tn.deinit();

    tn.cpu.a = 0xA5;
    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x52);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);

    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x29);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), false);

    tn.cpu.setFlag(CpuFlags.Carry, true);
    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x14);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);

    tn.cpu.a = 0x01;
    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x00);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
}
