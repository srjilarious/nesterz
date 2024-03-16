const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

pub fn cmpImmediateTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xC9, 16, // CMP #16
        0xC9, 0x1, // CMP #$1
    });
    defer tn.deinit();

    tn.cpu.a = 16;

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);
}

pub fn cmpZeroPageTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xC5, 0x10, // CMP $10
        0xC5, 0x12, // CMP $12
    });
    defer tn.deinit();

    tn.writeBytes(0x10, &[_]u8{ 16, 0x12, 0x01, 0xcd });
    tn.cpu.a = 16;

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.a, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);
}

pub fn cmpZeroPageXTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xD5, 0x10, // CMP $10
        0xD5, 0x12, // CMP $12
    });
    defer tn.deinit();

    tn.writeBytes(0x10, &[_]u8{ 0xcd, 0xcd, 16, 0x12, 0x01, 0xcd });
    tn.cpu.a = 16;
    tn.cpu.x = 2;

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);
}

pub fn cmpAbsoluteTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xCD, 0x10, 0x30, // CMP $3010
        0xCD, 0x12, 0x30, // CMP $3012
    });
    defer tn.deinit();

    tn.writeBytes(0x3010, &[_]u8{ 16, 0x12, 0x01, 0xcd });
    tn.cpu.a = 16;

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);
}

pub fn cmpAbsoluteXTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xDD, 0x10, 0x30, // CMP $3010,X
        0xDD, 0x12, 0x30, // CMP $3012,X
    });
    defer tn.deinit();

    tn.writeBytes(0x3015, &[_]u8{ 16, 0x12, 0x01, 0xcd });
    tn.cpu.a = 16;
    tn.cpu.x = 5;

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);
}

pub fn cmpAbsoluteYTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xD9, 0x10, 0x30, // CMP $3010,X
        0xD9, 0x12, 0x30, // CMP $3012,X
    });
    defer tn.deinit();

    tn.writeBytes(0x3015, &[_]u8{ 16, 0x12, 0x01, 0xcd });
    tn.cpu.a = 16;
    tn.cpu.y = 5;

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), true);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);

    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 16);
    try testz.expectEqual(tn.cpu.getFlag(.Zero), false);
    try testz.expectEqual(tn.cpu.getFlag(.Negative), false);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);
}

pub fn skip_cmpIndirectXTest() !void {}

pub fn skip_cmpIndirectYTest() !void {}
