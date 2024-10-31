const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

pub fn bitZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x24, 0x10, // BIT $10
        0x24, 0x11, // BIT $11
        0x24, 0x12, // BIT $12
    });
    defer tn.deinit();

    tn.writeBytes(0x10, &[_]u8{ 0x80, 0xfa, 0x0 });

    tn.cpu.a = 0xff;
    tn.cpu.setFlag(.Negative, false);
    tn.cpu.setFlag(.Overflow, true);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 0xff);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Overflow), false);

    tn.cpu.a = 0x0;
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Overflow), true);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Overflow), false);
}

pub fn skip_bitAbsoluteTest() !void {}
