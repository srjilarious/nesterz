const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");

const CpuFlags = nes.CpuFlags;

test "ASL Accumulator" {
    var tn = try fix.TestNes.initWithTesData(&std.testing.allocator, &[_]u8{
        0x0A, // ASL A
        0x0A, // ASL A
        0x0A, // ASL A
        0x0A, // ASL A
    });
    defer tn.deinit();

    tn.cpu.a = 0x51;

    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0xa2);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x44);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x88);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x10);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}

test "ASL ZeroPage" {
    var tn = try fix.TestNes.initWithTesData(&std.testing.allocator, &[_]u8{
        0x06, 0x10, // ASL $10
        0x06, 0x10, // ASL $10
        0x06, 0x10, // ASL $10
        0x06, 0x10, // ASL $10
    });
    defer tn.deinit();

    tn.writeByte(0x10, 0x51);

    try std.testing.expectEqual(try tn.tickInstruction(), 5);
    try std.testing.expectEqual(tn.readByte(0x10), 0xa2);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try std.testing.expectEqual(try tn.tickInstruction(), 5);
    try std.testing.expectEqual(tn.readByte(0x10), 0x44);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(try tn.tickInstruction(), 5);
    try std.testing.expectEqual(tn.readByte(0x10), 0x88);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try std.testing.expectEqual(try tn.tickInstruction(), 5);
    try std.testing.expectEqual(tn.readByte(0x10), 0x10);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}
