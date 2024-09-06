// zig-fmt: off
const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

pub fn sbcImmediateTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xE9, 0x10, // SBC #$10
        0xE9, 0x1, // SBC #$1
    });
    defer tn.deinit();

    // Start with the overflow flag set.
    tn.cpu.setFlag(.Carry, true);
    tn.cpu.a = 0x3;

    try testz.expectEqual(tn.tickInstruction(), 2);
    const res: i8 = -13;
    try testz.expectEqual(tn.cpu.a, @as(u8, @bitCast(res)));
    try testz.expectEqual(tn.cpu.getFlag(.Overflow), true);

    tn.cpu.setFlag(.Carry, true);
    const res2: i8 = -128;
    tn.cpu.a = @as(u8, @bitCast(res2));
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 127);
    try testz.expectEqual(tn.cpu.getFlag(.Overflow), false);
}

pub fn sbcZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xE5, 0x10, // SBC $10
        0xE5, 0x11, // SBC $11
    });
    defer tn.deinit();

    tn.writeBytes(0x10, &[_]u8{ 0x10, 0x1 });

    // Start with the overflow flag set.
    tn.cpu.setFlag(.Carry, true);
    tn.cpu.a = 0x3;

    try testz.expectEqual(tn.tickInstruction(), 3);
    const res: i8 = -13;
    try testz.expectEqual(tn.cpu.a, @as(u8, @bitCast(res)));
    try testz.expectEqual(tn.cpu.getFlag(.Overflow), true);

    tn.cpu.setFlag(.Carry, true);
    const res2: i8 = -128;
    tn.cpu.a = @as(u8, @bitCast(res2));
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 127);
    try testz.expectEqual(tn.cpu.getFlag(.Overflow), false);
}

pub fn sbcZeroPageXTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xF5, 0x10, // SBC $10,X
        0xF5, 0x11, // SBC $11,X
    });
    defer tn.deinit();

    tn.writeBytes(0x15, &[_]u8{ 0x10, 0x1 });

    // Start with the overflow flag set.
    tn.cpu.setFlag(.Carry, true);
    tn.cpu.a = 0x3;
    tn.cpu.x = 5;

    try testz.expectEqual(tn.tickInstruction(), 4);
    const res: i8 = -13;
    try testz.expectEqual(tn.cpu.a, @as(u8, @bitCast(res)));
    try testz.expectEqual(tn.cpu.getFlag(.Overflow), true);

    tn.cpu.setFlag(.Carry, true);
    const res2: i8 = -128;
    tn.cpu.a = @as(u8, @bitCast(res2));
    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 127);
    try testz.expectEqual(tn.cpu.getFlag(.Overflow), false);
}

pub fn skip_sbcAbsoluteTest() !void {}

pub fn skip_sbcAbsoluteXTest() !void {}

pub fn skip_sbcAbsoluteYTest() !void {}

pub fn skip_sbcIndirectXTest() !void {}

pub fn skip_sbcIndirectYTest() !void {}
