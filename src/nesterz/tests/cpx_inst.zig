const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

pub fn cpxImmediateTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xE0, 16, // CPX #16
        0xE0, 0x1, // CPX #$1
    });
    defer tn.deinit();

    tn.cpu.x = 16;

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.x, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.x, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);
}

pub fn cpxZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xE4, 0x10, // CPX $10
        0xE4, 0x12, // CPX $12
    });
    defer tn.deinit();

    tn.writeBytes(0x10, &[_]u8{ 16, 0x12, 0x01, 0xcd });
    tn.cpu.x = 16;

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.x, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.x, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);
}

pub fn cpxAbsoluteTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xEC, 0x10, 0x30, // CPX $3010
        0xEC, 0x12, 0x30, // CPX $3012
    });
    defer tn.deinit();

    tn.writeBytes(0x3010, &[_]u8{ 16, 0x12, 0x01, 0xcd });
    tn.cpu.x = 16;

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.x, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.x, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);
}
