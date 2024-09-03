const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

pub fn staZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x85, 0x10, // STA $10
        0x85, 0xff, // STA $ff
        0x85, 0x0, // STA 0
    });
    defer tn.deinit();

    tn.cpu.a = 23;
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.readByte(0x10), 23);

    tn.cpu.a = 0xaa;
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.readByte(0xff), 0xaa);

    tn.cpu.a = 0xcd;
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.readByte(0x0), 0xcd);
}

pub fn staZeroPageXTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x95, 0x10, // STA $10,X
        0x95, 0xff, // STA $ff,X
        0x95, 0x0, // STA 0,X
    });
    defer tn.deinit();

    tn.cpu.x = 0x10;
    tn.cpu.a = 23;
    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.readByte(0x20), 23);

    tn.cpu.a = 0xaa;
    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.readByte(0x0f), 0xaa);

    tn.cpu.a = 0xcd;
    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.readByte(0x10), 0xcd);
}

pub fn staAbsoluteTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x8D, 0x10, 0x30, // STA $3010
        0x8D, 0xff, 0x30, // STA $30ff
        0x8D, 0x0, 0x30, // STA $3000
    });
    defer tn.deinit();

    tn.cpu.a = 23;
    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.readByte(0x3010), 23);

    tn.cpu.a = 0xaa;
    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.readByte(0x30ff), 0xaa);

    tn.cpu.a = 0xcd;
    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.readByte(0x3000), 0xcd);
}

pub fn staAbsoluteXTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x9D, 0x10, 0x30, // STA $3010,X
        0x9D, 0x15, 0x30, // STA $3015,X
        0x9D, 0x0, 0x30, // STA $3000,X
    });
    defer tn.deinit();

    tn.cpu.a = 23;
    tn.cpu.x = 5;
    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x3015), 23);

    tn.cpu.a = 0xaa;
    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x301a), 0xaa);

    tn.cpu.a = 0xcd;
    try testz.expectEqual(tn.tickInstruction(), 5);
    try testz.expectEqual(tn.readByte(0x3005), 0xcd);
}

pub fn skip_staAbsoluteYTest() !void {}

pub fn skip_staIndirectXTest() !void {}

pub fn skip_staIndirectYTest() !void {}

// STX tets
//
pub fn stxZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x86, 0x10, // STX $10
        0x86, 0xff, // STX $ff
        0x86, 0x0, // STX 0
    });
    defer tn.deinit();

    tn.cpu.x = 23;
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.readByte(0x10), 23);

    tn.cpu.x = 0xaa;
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.readByte(0xff), 0xaa);

    tn.cpu.x = 0xcd;
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.readByte(0x0), 0xcd);
}

pub fn skip_stxZeroPageYTest() !void {}
pub fn skip_stxAbsoluteTest() !void {}

// STY tets
//
pub fn styZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x84, 0x10, // STX $10
        0x84, 0xff, // STX $ff
        0x84, 0x0, // STX 0
    });
    defer tn.deinit();

    tn.cpu.y = 23;
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.readByte(0x10), 23);

    tn.cpu.y = 0xaa;
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.readByte(0xff), 0xaa);

    tn.cpu.y = 0xcd;
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.readByte(0x0), 0xcd);
}

pub fn skip_styZeroPageYTest() !void {}
pub fn skip_styAbsoluteTest() !void {}
