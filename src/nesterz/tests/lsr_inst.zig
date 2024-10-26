const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

pub fn lsrAccumulatorTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x4A, // LSR A
        0x4A, // LSR A
        0x4A, // LSR A
        0x4A, // LSR A
    });
    defer tn.deinit();

    tn.cpu.a = 0xA5;
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x52);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x29);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), false);

    tn.cpu.setFlag(CpuFlags.Carry, true);
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x14);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);

    tn.cpu.a = 0x01;
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x00);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
}

pub fn lsrZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x46, 0x10, // LSR $10
        0x46, 0x10, // LSR $10
        0x46, 0x10, // LSR $10
        0x46, 0x10, // LSR $10
    });
    defer tn.deinit();

    tn.writeByte(0x10, 0xa5);
    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x10), 0x52);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);

    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x10), 0x29);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), false);

    tn.cpu.setFlag(CpuFlags.Carry, true);
    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x10), 0x14);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);

    tn.writeByte(0x10, 0x1);
    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x10), 0x00);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
}

pub fn lsrZeroPageXTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x56, 0x0d, // LSR $0d,X
        0x56, 0x0d, // LSR $0d,X
        0x56, 0x0d, // LSR $0d,X
        0x56, 0x0d, // LSR $0d,X
    });
    defer tn.deinit();

    tn.writeByte(0x10, 0xa5);
    tn.cpu.x = 0x3;

    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x10), 0x52);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);

    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x10), 0x29);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), false);

    tn.cpu.setFlag(CpuFlags.Carry, true);
    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x10), 0x14);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);

    tn.writeByte(0x10, 0x1);
    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x10), 0x00);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
}

pub fn lsrAsoluteTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x4E, 0x10, 0x30, // LSR $3010
        0x4E, 0x10, 0x30, // LSR $3010
        0x4E, 0x10, 0x30, // LSR $3010
        0x4E, 0x10, 0x30, // LSR $3010
    });
    defer tn.deinit();

    tn.writeByte(0x3010, 0xa5);
    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x3010), 0x52);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);

    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x3010), 0x29);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), false);

    tn.cpu.setFlag(CpuFlags.Carry, true);
    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x3010), 0x14);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);

    tn.writeByte(0x3010, 0x1);
    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x3010), 0x00);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
}

pub fn lsrAsoluteXTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x5E, 0x0d, 0x30, // LSR $300d,X
        0x5E, 0x0d, 0x30, // LSR $300d,X
        0x5E, 0x0d, 0x30, // LSR $300d,X
        0x5E, 0x0d, 0x30, // LSR $300d,X
    });
    defer tn.deinit();

    tn.writeByte(0x3010, 0xa5);
    tn.cpu.x = 0x3;

    try testz.expectEqual(tn.tickInstruction(), 7);
    try testz.expectEqual(tn.readByte(0x3010), 0x52);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);

    try testz.expectEqual(tn.tickInstruction(), 7);
    try testz.expectEqual(tn.readByte(0x3010), 0x29);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), false);

    tn.cpu.setFlag(CpuFlags.Carry, true);
    try testz.expectEqual(tn.tickInstruction(), 7);
    try testz.expectEqual(tn.readByte(0x3010), 0x14);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);

    tn.writeByte(0x3010, 0x1);
    try testz.expectEqual(tn.tickInstruction(), 7);
    try testz.expectEqual(tn.readByte(0x3010), 0x00);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Carry), true);
}
