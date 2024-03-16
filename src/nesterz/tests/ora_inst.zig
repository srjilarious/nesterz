const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

pub fn oraImmediateTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x09, 0x0, // ORA #$0
        0x09, 0x44, // ORA #$44
        0x09, 0x22, // ORA #$22
        0x09, 0x81, // ORA #$81
    });
    defer tn.deinit();

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    tn.cpu.a = 0x10;

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x54);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x76);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x0f7);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
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

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    tn.cpu.a = 0x10;

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 0x54);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 0x76);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 0x0f7);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
}

pub fn oraZeroPageXTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x15, 0x10, // ORA $10,X
        0x15, 0x11, // ORA $11,X
        0x15, 0x12, // ORA $12,X
        0x15, 0x13, // ORA $13,X
    });
    defer tn.deinit();

    tn.writeBytes(0x14, &[_]u8{ 0x0, 0x44, 0x22, 0x81 });
    tn.cpu.x = 0x4;

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    tn.cpu.a = 0x10;

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x54);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x76);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x0f7);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
}
