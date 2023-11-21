const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");

const CpuFlags = nes.CpuFlags;

pub fn lsrAccumulatorTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x4A, // LSR A
        0x4A, // LSR A
        0x4A, // LSR A
        0x4A, // LSR A
    });
    defer tn.deinit();

    tn.cpu.a = 0xA5;
    try std.testing.expectEqual(tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x52);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);

    try std.testing.expectEqual(tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x29);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), false);

    tn.cpu.setFlag(CpuFlags.Carry, true);
    try std.testing.expectEqual(tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x14);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);

    tn.cpu.a = 0x01;
    try std.testing.expectEqual(tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x00);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
}

pub fn lsrZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x46, 0x10, // LSR $10
        0x46, 0x10, // LSR $10
        0x46, 0x10, // LSR $10
        0x46, 0x10, // LSR $10
    });
    defer tn.deinit();

    tn.writeByte(0x10, 0xa5);
    try std.testing.expectEqual(tn.tickInstruction(), 5);
    try std.testing.expectEqual(tn.readByte(0x10), 0x52);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);

    try std.testing.expectEqual(tn.tickInstruction(), 5);
    try std.testing.expectEqual(tn.readByte(0x10), 0x29);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), false);

    tn.cpu.setFlag(CpuFlags.Carry, true);
    try std.testing.expectEqual(tn.tickInstruction(), 5);
    try std.testing.expectEqual(tn.readByte(0x10), 0x14);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);

    tn.writeByte(0x10, 0x1);
    try std.testing.expectEqual(tn.tickInstruction(), 5);
    try std.testing.expectEqual(tn.readByte(0x10), 0x00);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
}
