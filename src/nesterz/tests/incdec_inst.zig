const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("./test_runner.zig");

const CpuFlags = nes.CpuFlags;

pub fn incZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xE6, 0x10, // INC $10
        0xE6, 0x11, // INC $11
        0xE6, 0x12, // INC $12
        0xE6, 0x10, // INC $10
    });
    defer tn.deinit();

    tn.writeBytes(0x10, &[_]u8{ 30, 0xff, 0xfe });

    try std.testing.expectEqual(tn.tickInstruction(), 5);
    try std.testing.expectEqual(tn.readByte(0x10), 31);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(tn.tickInstruction(), 5);
    try std.testing.expectEqual(tn.readByte(0x11), 0);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(tn.tickInstruction(), 5);
    try std.testing.expectEqual(tn.readByte(0x12), 0xff);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try std.testing.expectEqual(tn.tickInstruction(), 5);
    try std.testing.expectEqual(tn.readByte(0x10), 32);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(120, 0xff);
}
