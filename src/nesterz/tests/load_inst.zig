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

pub fn ldaZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xA5, 0x10, // LDA $10
        0xA5, 0x11, // LDA $11
        0xA5, 0x12, // LDA $12
    });
    defer tn.deinit();

    tn.writeBytes(0x10, &[_]u8{ 0xff, 0x42, 0x0 });
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 0xff);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 0x42);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}

pub fn ldaZeroPageXTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xB5, 0x10, // LDA $10,X
        0xB5, 0x11, // LDA $11,X
        0xB5, 0x12, // LDA $12,X
    });
    defer tn.deinit();

    tn.cpu.x = 5;

    tn.writeBytes(0x15, &[_]u8{ 0xff, 0x42, 0x0 });
    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0xff);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x42);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}

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
