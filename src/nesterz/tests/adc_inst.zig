const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");

const CpuFlags = nes.CpuFlags;

pub fn adcImmediateTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x69, 0x0, // ADC #$0
        0x69, 0x10, // ADC #$10
        0x69, 0x35, // ADC #$35
        0x69, 0x85, // ADC #$85
    });
    defer tn.deinit();

    tn.cpu.a = 0x0;

    try std.testing.expectEqual(tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x0);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x10);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x45);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0xca);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
    std.debug.print("About to error return!\n", .{});
    try std.testing.expectEqual(true, false);
    std.debug.print("Forcing error return!\n", .{});
    return error.TestExpectedEqual;
}

pub fn adcZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x65, 0x10, // ADC $10
        0x65, 0x11, // ADC $11
        0x65, 0x13, // ADC $14
        0x65, 0x15, // ADC $15
    });
    defer tn.deinit();

    tn.writeBytes(0x10, &[_]u8{ 0x0, 0x10, 0xcd, 0x35, 0xcd, 0x85 });

    tn.cpu.a = 0x0;

    try std.testing.expectEqual(tn.tickInstruction(), 3);
    try std.testing.expectEqual(tn.cpu.a, 0x0);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(tn.tickInstruction(), 3);
    try std.testing.expectEqual(tn.cpu.a, 0x10);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(tn.tickInstruction(), 3);
    try std.testing.expectEqual(tn.cpu.a, 0x45);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(tn.tickInstruction(), 3);
    try std.testing.expectEqual(tn.cpu.a, 0xca);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
}
