const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

// LDA instruction tests.
//
pub fn ldaImmediateTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xA9, 7, // LDA 7
        0xA9, 0xff, // LDA $ff
        0xA9, 0, // LDA 0
    });
    defer tn.deinit();

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 7);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0xff);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}

pub fn skip_ldaZeroPageTest() !void {}

pub fn skip_ldaZeroPageXTest() !void {}

pub fn skip_ldaAbsoluteTest() !void {}

pub fn skip_ldaAbsoluteXTest() !void {}

pub fn skip_ldaAbsoluteYTest() !void {}

pub fn skip_ldaIndirectXTest() !void {}

pub fn skip_ldaIndirectYTest() !void {}

// LDX instruction tests.
//
pub fn skip_ldxImmediateTest() !void {}

pub fn skip_ldxZeroPageTest() !void {}

pub fn skip_ldxZeroPageYTest() !void {}

pub fn skip_ldxAbsoluteTest() !void {}

pub fn skip_ldxAbsoluteYTest() !void {}

// LDY instruction tests.
//
pub fn skip_ldyImmediateTest() !void {}

pub fn skip_ldyZeroPageTest() !void {}

pub fn skip_ldyZeroPageXTest() !void {}

pub fn skip_ldyAbsoluteTest() !void {}

pub fn skip_ldyAbsoluteXTest() !void {}
