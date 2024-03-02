const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("test_runner.zig");

const CpuFlags = nes.CpuFlags;

pub fn cmpImmediateTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xC9, 16, // ADC #$0
        0xC9, 0x1, // ADC #$10
    });
    defer tn.deinit();

    tn.cpu.a = 16;

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);
}

pub fn skip_cmpZeroPageTest() !void {}

pub fn skip_cmpZeroPageXTest() !void {}

pub fn skip_cmpAbsoluteTest() !void {}

pub fn skip_cmpAbsoluteXTest() !void {}

pub fn skip_cmpAbsoluteYTest() !void {}

pub fn skip_cmpIndirectXTest() !void {}

pub fn skip_cmpIndirectYTest() !void {}
