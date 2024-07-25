// zig fmt: off
const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

pub fn bplTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator,
    &[_]u8{
        0x10, 0x12, // BPL #$12 -- fall through
        0x10, 0x10, // BPL #$10 -- jump PC + 16 
    });
    defer tn.deinit();

    // BPL 0x200 + 0x14 is 0x214 
    // This instruction will jump back 22 
    // (0xea is minus 0x14)
    tn.writeBytes(0x214, &[_]u8{0x10, 0xea});

    tn.cpu.setFlag(.Negative, true);
    // 2 since jump failed
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.pc, 0x203);

    // 3 since jump needed
    tn.cpu.setFlag(.Negative, false);
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.pc, 0x215);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.pc, 0x201);
}

pub fn bmiTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator,
    &[_]u8{
        0x30, 0x12, // BMI #$12 -- fall through
        0x30, 0x10, // BMI #$10 -- jump PC + 16 
    });
    defer tn.deinit();

    // BMI 0x200 + 0x14 is 0x214 
    // This instruction will jump back 22 
    // (0xea is minus 0x14)
    tn.writeBytes(0x214, &[_]u8{0x30, 0xea});

    tn.cpu.setFlag(.Negative, false);
    // 2 since jump failed
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.pc, 0x203);

    // 3 since jump needed
    tn.cpu.setFlag(.Negative, true);
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.pc, 0x215);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.pc, 0x201);
}

pub fn beqTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator,
    &[_]u8{
        0xF0, 0x12, // BEQ #$12 -- fall through
        0xF0, 0x10, // BEQ #$10 -- jump PC + 16 
    });
    defer tn.deinit();

    // BEQ 0x200 + 0x14 is 0x214 
    // This instruction will jump back 22 
    // (0xea is minus 0x14)
    tn.writeBytes(0x214, &[_]u8{0xF0, 0xea});

    tn.cpu.setFlag(.Zero, false);
    // 2 since jump failed
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.pc, 0x203);

    // 3 since jump needed
    tn.cpu.setFlag(.Zero, true);
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.pc, 0x215);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.pc, 0x201);
}

pub fn bneTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator,
    &[_]u8{
        0xD0, 0x12, // BNE #$12 -- fall through
        0xD0, 0x10, // BNE #$10 -- jump PC + 16 
    });
    defer tn.deinit();

    // BNE 0x200 + 0x14 is 0x214 
    // This instruction will jump back 22 
    // (0xea is minus 0x14)
    tn.writeBytes(0x214, &[_]u8{0xD0, 0xea});

    tn.cpu.setFlag(.Zero, true);
    // 2 since jump failed
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.pc, 0x203);

    // 3 since jump needed
    tn.cpu.setFlag(.Zero, false);
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.pc, 0x215);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.pc, 0x201);
}

pub fn skip_bccTest() !void {

}

pub fn skip_bcsTest() !void {

}

pub fn skip_bvcTest() !void {

}

pub fn skip_bvsTest() !void {

}

