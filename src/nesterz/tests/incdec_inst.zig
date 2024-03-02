const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("./test_runner.zig");

const CpuFlags = nes.CpuFlags;

pub fn incZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xE6, 0x10, // INC $10
        0xE6, 0x11, // INC $11
        0xE6, 0x12, // INC $12
        0xE6, 0x10, // INC $10
    });
    defer tn.deinit();

    tn.writeBytes(0x10, &[_]u8{ 30, 0xff, 0xfe });

    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x10), 31);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x11), 0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x12), 0xff);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x10), 32);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    //try testz.expectEqual(120, 0xff);
}

pub fn decZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xC6, 0x10, // DEC $10
        0xC6, 0x11, // DEC $11
        0xC6, 0x12, // DEC $12
        0xC6, 0x10, // DEC $10
    });
    defer tn.deinit();

    tn.writeBytes(0x10, &[_]u8{ 30, 0x00, 0x01 });

    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x10), 29);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x11), 0xff);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x12), 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x10), 28);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    //try testz.expectEqual(120, 0xff);
}

pub fn skip_decZeroPageXTest() !void {}

pub fn skip_decAbsoluteTest() !void {}

pub fn skip_decAbsoluteXTest() !void {}
