const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

pub fn eorImmediateTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x49, 0xaa, // EOR #$AA
        0x49, 0x22, // EOR #$22
        0x49, 0xf5, // EOR #$F5
    });
    defer tn.deinit();

    tn.cpu.a = 0x88;

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x22);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0xf5);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
}

pub fn skip_eorZeroPageTest() !void {}

pub fn skip_eorZeroPageXTest() !void {}

pub fn skip_eorZeroPageYTest() !void {}

pub fn skip_eorAbsoluteTest() !void {}

pub fn skip_eorAbsoluteXTest() !void {}

pub fn skip_eorIndirectXTest() !void {}

pub fn skip_eorIndirectYTest() !void {}
