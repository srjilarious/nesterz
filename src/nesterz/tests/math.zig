const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");

const CpuFlags = nes.CpuFlags;

// ----------------------------------------------------------------------------
// AND Instruction tests
// ----------------------------------------------------------------------------
test "AND Immediate" {
    var tn = try fix.TestNes.initWithTesData(&std.testing.allocator, &[_]u8{
        0x29, 0xfb, // AND #$fb
        0x29, 0xab, // AND #$ab
        0x29, 0x22, // AND #$22
        0x29, 0x00, // AND #$0
    });
    defer tn.deinit();

    tn.cpu.a = 0xff;

    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0xfb);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0xab);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x22);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x0);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}

test "AND ZeroPage" {
    var tn = try fix.TestNes.initWithTesData(&std.testing.allocator, &[_]u8{
        0x25, 0x10, // AND $10
        0x25, 0x11, // AND $11
        0x25, 0x12, // AND $12
        0x25, 0x13, // AND $13
    });
    defer tn.deinit();

    tn.writeBytes(0x10, &[_]u8{ 0xfb, 0xab, 0x22, 0x0 });

    tn.cpu.a = 0xff;

    try std.testing.expectEqual(try tn.tickInstruction(), 3);
    try std.testing.expectEqual(tn.cpu.a, 0xfb);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try std.testing.expectEqual(try tn.tickInstruction(), 3);
    try std.testing.expectEqual(tn.cpu.a, 0xab);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try std.testing.expectEqual(try tn.tickInstruction(), 3);
    try std.testing.expectEqual(tn.cpu.a, 0x22);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try std.testing.expectEqual(try tn.tickInstruction(), 3);
    try std.testing.expectEqual(tn.cpu.a, 0x0);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try std.testing.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}

// ----------------------------------------------------------------------------
// ADC Instruction tests
// ----------------------------------------------------------------------------
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

// ----------------------------------------------------------------------------
// ADC Instruction tests
// ----------------------------------------------------------------------------
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
