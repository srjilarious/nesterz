const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");

const CpuFlags = nes.CpuFlags;

test "ADC Immediate" {
    var tn = try fix.TestNes.initWithTesData(&std.testing.allocator, &[_]u8{
        0x69, 0x0, // ADC #$0
        0x69, 0x10, // ADC #$10
        0x69, 0x35, // ADC #$35
        0x69, 0x85, // ADC #$85
    });
    defer tn.deinit();

    tn.cpu.a = 0x0;

    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x0);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x10);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x45);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0xca);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
}

test "ADC ZeroPage" {
    var tn = try fix.TestNes.initWithTesData(&std.testing.allocator, &[_]u8{
        0x65, 0x10, // ADC $10
        0x65, 0x11, // ADC $11
        0x65, 0x13, // ADC $14
        0x65, 0x15, // ADC $15
    });
    defer tn.deinit();

    tn.writeBytes(0x10, &[_]u8{ 0x0, 0x10, 0xcd, 0x35, 0xcd, 0x85 });

    tn.cpu.a = 0x0;

    try std.testing.expectEqual(try tn.tickInstruction(), 3);
    try std.testing.expectEqual(tn.cpu.a, 0x0);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(try tn.tickInstruction(), 3);
    try std.testing.expectEqual(tn.cpu.a, 0x10);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(try tn.tickInstruction(), 3);
    try std.testing.expectEqual(tn.cpu.a, 0x45);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(try tn.tickInstruction(), 3);
    try std.testing.expectEqual(tn.cpu.a, 0xca);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
}
