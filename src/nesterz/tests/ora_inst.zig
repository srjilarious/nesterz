const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("test_runner.zig");

const CpuFlags = nes.CpuFlags;

pub fn oraImmediateTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x09, 0x0, // ORA #$0
        0x09, 0x44, // ORA #$44
        0x09, 0x22, // ORA #$22
        0x09, 0x81, // ORA #$81
    });
    defer tn.deinit();

    try std.testing.expectEqual(tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x0);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    tn.cpu.a = 0x10;

    try std.testing.expectEqual(tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x54);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x76);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x0f7);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
}

pub fn oraZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x05, 0x10, // ORA $10
        0x05, 0x11, // ORA $11
        0x05, 0x12, // ORA $12
        0x05, 0x13, // ORA $13
    });
    defer tn.deinit();

    tn.writeBytes(0x10, &[_]u8{ 0x0, 0x44, 0x22, 0x81 });

    try std.testing.expectEqual(tn.tickInstruction(), 3);
    try std.testing.expectEqual(tn.cpu.a, 0x0);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    tn.cpu.a = 0x10;

    try std.testing.expectEqual(tn.tickInstruction(), 3);
    try std.testing.expectEqual(tn.cpu.a, 0x54);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(tn.tickInstruction(), 3);
    try std.testing.expectEqual(tn.cpu.a, 0x76);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(tn.tickInstruction(), 3);
    try std.testing.expectEqual(tn.cpu.a, 0x0f7);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
}
