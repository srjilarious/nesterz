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

    tn.cpu.a = 0xAD;

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

pub fn rolZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x26, 0x50, // ROL $50
        0x26, 0x50, // ROL $50
        0x26, 0x50, // ROL $50
    });
    defer tn.deinit();

    tn.writeByte(0x50, 0xAD);

    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x50), 0x5a);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x50), 0xB5);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x50), 0x6A);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}

pub fn rolZeroPageXTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x36, 0x50, // ROL $50,X
        0x36, 0x50, // ROL $50,X
        0x36, 0x50, // ROL $50,X
    });
    defer tn.deinit();

    tn.writeByte(0x5A, 0xAD);
    tn.cpu.x = 0xA;
    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x5A), 0x5a);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x5A), 0xB5);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x5A), 0x6A);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}

pub fn skip_rolAbsoluteTest() !void {}

pub fn skip_rolAbsoluteXTest() !void {}
