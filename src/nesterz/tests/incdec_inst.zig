const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

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

pub fn skip_incZeroPageXTest() !void {}

pub fn skip_incAbsoluteTest() !void {}

pub fn skip_incAbsoluteXTest() !void {}

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

pub fn decZeroPageXTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xD6, 0x10, // DEC $10
        0xD6, 0x11, // DEC $11
        0xD6, 0x12, // DEC $12
        0xD6, 0x10, // DEC $10
    });
    defer tn.deinit();

    tn.writeBytes(0x15, &[_]u8{ 30, 0x00, 0x01 });
    tn.cpu.x = 5;

    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x15), 29);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x16), 0xff);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), true);

    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x17), 0x0);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);

    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.readByte(0x15), 28);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(CpuFlags.Negative), false);
}

pub fn skip_decAbsoluteTest() !void {}

pub fn skip_decAbsoluteXTest() !void {}

pub fn inxTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xE8, // INX
        0xE8, // INX
        0xE8, // INX
        0xE8, // INX
    });
    defer tn.deinit();

    tn.cpu.x = 253;

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.x, 254);
    try testz.expectFalse(tn.cpu.getFlag(.Zero));
    try testz.expectTrue(tn.cpu.getFlag(.Negative));

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.x, 255);
    try testz.expectFalse(tn.cpu.getFlag(.Zero));
    try testz.expectTrue(tn.cpu.getFlag(.Negative));

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.x, 0);
    try testz.expectTrue(tn.cpu.getFlag(.Zero));
    try testz.expectFalse(tn.cpu.getFlag(.Negative));

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.x, 1);
    try testz.expectFalse(tn.cpu.getFlag(.Zero));
    try testz.expectFalse(tn.cpu.getFlag(.Negative));
}

pub fn dexTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xCA, // DEX
        0xCA, // DEX
        0xCA, // DEX
        0xCA, // DEX
    });
    defer tn.deinit();

    tn.cpu.x = 2;

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.x, 1);
    try testz.expectFalse(tn.cpu.getFlag(.Zero));
    try testz.expectFalse(tn.cpu.getFlag(.Negative));

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.x, 0);
    try testz.expectTrue(tn.cpu.getFlag(.Zero));
    try testz.expectFalse(tn.cpu.getFlag(.Negative));

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.x, 255);
    try testz.expectFalse(tn.cpu.getFlag(.Zero));
    try testz.expectTrue(tn.cpu.getFlag(.Negative));

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.x, 254);
    try testz.expectFalse(tn.cpu.getFlag(.Zero));
    try testz.expectTrue(tn.cpu.getFlag(.Negative));
}

pub fn inyTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xC8, // INY
        0xC8, // INY
        0xC8, // INY
        0xC8, // INY
    });
    defer tn.deinit();

    tn.cpu.y = 253;

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.y, 254);
    try testz.expectFalse(tn.cpu.getFlag(.Zero));
    try testz.expectTrue(tn.cpu.getFlag(.Negative));

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.y, 255);
    try testz.expectFalse(tn.cpu.getFlag(.Zero));
    try testz.expectTrue(tn.cpu.getFlag(.Negative));

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.y, 0);
    try testz.expectTrue(tn.cpu.getFlag(.Zero));
    try testz.expectFalse(tn.cpu.getFlag(.Negative));

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.y, 1);
    try testz.expectFalse(tn.cpu.getFlag(.Zero));
    try testz.expectFalse(tn.cpu.getFlag(.Negative));
}

pub fn deyTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x88, // DEY
        0x88, // DEY
        0x88, // DEY
        0x88, // DEY
    });
    defer tn.deinit();

    tn.cpu.y = 2;

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.y, 1);
    try testz.expectFalse(tn.cpu.getFlag(.Zero));
    try testz.expectFalse(tn.cpu.getFlag(.Negative));

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.y, 0);
    try testz.expectTrue(tn.cpu.getFlag(.Zero));
    try testz.expectFalse(tn.cpu.getFlag(.Negative));

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.y, 255);
    try testz.expectFalse(tn.cpu.getFlag(.Zero));
    try testz.expectTrue(tn.cpu.getFlag(.Negative));

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.y, 254);
    try testz.expectFalse(tn.cpu.getFlag(.Zero));
    try testz.expectTrue(tn.cpu.getFlag(.Negative));
}
