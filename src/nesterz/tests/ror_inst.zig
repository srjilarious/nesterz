const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

pub fn rorAccumulatorTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x6A, // ROR A
        0x6A, // ROR A
        0x6A, // ROR A
    });
    defer tn.deinit();

    tn.cpu.a = 0xAd;

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x56);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0xAB);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x55);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}

pub fn rorZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x66, 0x50, // ROR $50
        0x66, 0x50, // ROR $50
        0x66, 0x50, // ROR $50
    });
    defer tn.deinit();

    tn.writeByte(0x50, 0xAD);
    tn.cpu.a = 0xAD;

    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x50), 0x56);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x50), 0xAB);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x50), 0x55);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}

pub fn skip_rorZeroPageXTest() !void {}

pub fn skip_rorAbsoluteTest() !void {}

pub fn skip_rorAbsoluteXTest() !void {}
