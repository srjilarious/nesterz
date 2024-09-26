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

    tn.cpu.a = 0xAD;

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

pub fn rorZeroPageXTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x76, 0x50, // ROR $50,X
        0x76, 0x50, // ROR $50,X
        0x76, 0x50, // ROR $50,X
    });
    defer tn.deinit();

    tn.writeByte(0x5A, 0xAD);
    tn.cpu.x = 0xA;

    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x5A), 0x56);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x5A), 0xAB);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x5A), 0x55);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}

pub fn rorAbsoluteTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x6E, 0x50, 0x30, // ROR $3050
        0x6E, 0x50, 0x30, // ROR $3050
        0x6E, 0x50, 0x30, // ROR $3050
    });
    defer tn.deinit();

    tn.writeByte(0x3050, 0xAD);

    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x3050), 0x56);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x3050), 0xAB);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x3050), 0x55);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}

pub fn rorAbsoluteXTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x7E, 0x50, 0x30, // ROR $3050,X
        0x7E, 0x50, 0x30, // ROR $3050,X
        0x7E, 0x50, 0x30, // ROR $3050,X
    });
    defer tn.deinit();

    tn.writeByte(0x305A, 0xAD);
    tn.cpu.x = 0xA;

    try testz.expectEqual(tn.tickInstruction(), 7);
    try testz.expectEqual(tn.readByte(0x305A), 0x56);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 7);
    try testz.expectEqual(tn.readByte(0x305A), 0xAB);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 7);
    try testz.expectEqual(tn.readByte(0x305A), 0x55);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}
