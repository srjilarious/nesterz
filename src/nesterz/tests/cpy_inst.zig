const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("test_runner.zig");

const CpuFlags = nes.CpuFlags;

pub fn cpyImmediateTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xC0, 16, // CPXY#16
        0xC0, 0x1, // CPY #$1
    });
    defer tn.deinit();

    tn.cpu.y = 16;

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.y, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.y, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);
}

pub fn skip_cpyZeroPageTest() !void {}

pub fn skip_cpyAbsoluteTest() !void {}
