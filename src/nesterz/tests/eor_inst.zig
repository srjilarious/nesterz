const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

pub fn eorImmediateTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x49, 0xaa, // EOR #$AA
        0x49, 0x22, // EOR #$22
        0x49, 0xf5, // EOR #$F5
    });
    defer tn.deinit();

    tn.cpu.a = 0x88;

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x22);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0xf5);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
}

pub fn eorZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x45, 0x10, // EOR $10 ($AA)
        0x45, 0x11, // EOR $11 ($22)
        0x45, 0x12, // EOR $12 ($F5)
    });
    defer tn.deinit();

    tn.writeBytes(0x10, &[_]u8{ 0xaa, 0x22, 0xf5 });
    tn.cpu.a = 0x88;

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 0x22);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 0xf5);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
}

pub fn eorZeroPageXTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x55, 0x10, // EOR $10,X ($AA)
        0x55, 0x11, // EOR $11,X ($22)
        0x55, 0x12, // EOR $12,X ($F5)
    });
    defer tn.deinit();

    tn.writeBytes(0x15, &[_]u8{ 0xaa, 0x22, 0xf5 });
    tn.cpu.x = 5;
    tn.cpu.a = 0x88;

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x22);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0xf5);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
}

pub fn eorAbsoluteTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x4d, 0x10, 0x30, // EOR $3010 ($AA)
        0x4d, 0x11, 0x30, // EOR $3011 ($22)
        0x4d, 0x12, 0x30, // EOR $3012 ($F5)
    });
    defer tn.deinit();

    tn.writeBytes(0x3010, &[_]u8{ 0xaa, 0x22, 0xf5 });
    tn.cpu.a = 0x88;

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x22);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0xf5);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
}

pub fn eorAbsoluteXTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x5d, 0x10, 0x30, // EOR $3010,X ($AA)
        0x5d, 0x11, 0x30, // EOR $3011,X ($22)
        0x5d, 0x12, 0x30, // EOR $3012,X ($F5)
    });
    defer tn.deinit();

    tn.writeBytes(0x3015, &[_]u8{ 0xaa, 0x22, 0xf5 });
    tn.cpu.a = 0x88;
    tn.cpu.x = 5;

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x22);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0xf5);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
}

pub fn eorAbsoluteYTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x59, 0x10, 0x30, // EOR $3010,Y ($AA)
        0x59, 0x11, 0x30, // EOR $3011,Y ($22)
        0x59, 0x12, 0x30, // EOR $3012,Y ($F5)
    });
    defer tn.deinit();

    tn.writeBytes(0x3015, &[_]u8{ 0xaa, 0x22, 0xf5 });
    tn.cpu.a = 0x88;
    tn.cpu.y = 5;

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x22);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0xf5);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
}

pub fn eorIndirectXTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x41, 0x20, // EOR ($20,X) ($AA)
        0x41, 0x22, // EOR ($22,X) ($22)
        0x41, 0x26, // EOR ($26,X) ($F5)
    });
    defer tn.deinit();

    tn.printDebug = true;
    tn.writeBytes(0x23, &[_]u8{ 0x01, 0x10, 0x02, 0x20, 0xcd, 0xef, 0x03, 0x30 });

    tn.writeByte(0x1001, 0xaa);
    tn.writeByte(0x2002, 0x22);
    tn.writeByte(0x3003, 0xf5);

    tn.cpu.a = 0x88;
    tn.cpu.x = 3;

    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.cpu.a, 0x22);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.cpu.a, 0xf5);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
}

pub fn eorIndirectYTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x51, 0x20, // EOR ($20),Y ($AA)
        0x51, 0x22, // EOR ($22),Y ($22)
        0x51, 0x26, // EOR ($26),Y ($F5)
    });
    defer tn.deinit();

    tn.printDebug = true;
    tn.writeBytes(0x20, &[_]u8{ 0x01, 0x10, 0x02, 0x20, 0xcd, 0xef, 0x03, 0x30 });

    tn.writeByte(0x1004, 0xaa);
    tn.writeByte(0x2005, 0x22);
    tn.writeByte(0x3006, 0xf5);

    tn.cpu.a = 0x88;
    tn.cpu.y = 3;

    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.cpu.a, 0x22);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.cpu.a, 0xf5);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);
}
