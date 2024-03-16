const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

pub fn andImmediateTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x29, 0xfb, // AND #$fb
        0x29, 0xab, // AND #$ab
        0x29, 0x22, // AND #$22
        0x29, 0x00, // AND #$0
    });
    defer tn.deinit();

    tn.cpu.a = 0xff;

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0xfb);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0xab);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x22);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}

pub fn andZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x25, 0x10, // AND $10
        0x25, 0x11, // AND $11
        0x25, 0x12, // AND $12
        0x25, 0x13, // AND $13
    });
    defer tn.deinit();

    tn.writeBytes(0x10, &[_]u8{ 0xfb, 0xab, 0x22, 0x0 });

    tn.cpu.a = 0xff;

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 0xfb);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 0xab);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 0x22);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}

pub fn andZeroPageXTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x35, 0x10, // AND $10,X
        0x35, 0x11, // AND $11,X
        0x35, 0x12, // AND $12,X
        0x35, 0x13, // AND $13,X
    });
    defer tn.deinit();

    tn.writeBytes(0x15, &[_]u8{ 0xfb, 0xab, 0x22, 0x0 });

    tn.cpu.a = 0xff;
    tn.cpu.x = 5;
    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0xfb);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0xab);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x22);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}

pub fn andAbsoluteTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x2D, 0x10, 0x30, // AND $3010
        0x2D, 0x11, 0x30, // AND $3011
        0x2D, 0x12, 0x30, // AND $3012
        0x2D, 0x13, 0x30, // AND $3013
    });
    defer tn.deinit();

    tn.writeBytes(0x3010, &[_]u8{ 0xfb, 0xab, 0x22, 0x0 });

    tn.cpu.a = 0xff;

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0xfb);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0xab);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x22);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}

pub fn andAbsoluteXTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x3D, 0x10, 0x30, // AND $3010,X
        0x3D, 0x11, 0x30, // AND $3011,X
        0x3D, 0x12, 0x30, // AND $3012,X
        0x3D, 0x13, 0x30, // AND $3013,X
    });
    defer tn.deinit();

    tn.writeBytes(0x3013, &[_]u8{ 0xfb, 0xab, 0x22, 0x0 });

    tn.cpu.a = 0xff;
    tn.cpu.x = 3;

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0xfb);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0xab);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x22);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}

pub fn skip_andIndirectXTest() !void {}

pub fn skip_andIndirectYTest() !void {}
