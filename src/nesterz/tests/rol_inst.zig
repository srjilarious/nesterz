const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

pub fn rolAccumulatorTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x2A, // ROL A
        0x2A, // ROL A
        0x2A, // ROL A
    });
    defer tn.deinit();

    tn.cpu.a = 0xAd;

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x5a);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0xB5);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x6A);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}

pub fn skip_rolZeroPageTest() !void {}

pub fn skip_rolZeroPageXTest() !void {}

pub fn skip_rolAbsoluteTest() !void {}

pub fn skip_rolAbsoluteXTest() !void {}
