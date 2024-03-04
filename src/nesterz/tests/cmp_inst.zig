const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("test_runner.zig");

const CpuFlags = nes.CpuFlags;

pub fn cmpImmediateTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xC9, 16, // CMP #16
        0xC9, 0x1, // CMP #$1
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

pub fn cmpZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xC5, 0x10, // CMP $10
        0xC5, 0x12, // CMP $12
    });
    defer tn.deinit();

    tn.writeBytes(0x10, &[_]u8{ 16, 0x12, 0x01, 0xcd });
    tn.cpu.a = 16;

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);
}

pub fn skip_cmpZeroPageXTest() !void {}

pub fn skip_cmpAbsoluteTest() !void {}

pub fn skip_cmpAbsoluteXTest() !void {}

pub fn skip_cmpAbsoluteYTest() !void {}

pub fn skip_cmpIndirectXTest() !void {}

pub fn skip_cmpIndirectYTest() !void {}
