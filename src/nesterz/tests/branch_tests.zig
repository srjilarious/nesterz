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

pub fn bccTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator,
    &[_]u8{
        0x90, 0x12, // BCC #$12 -- fall through
        0x90, 0x10, // BCC #$10 -- jump PC + 16 
    });
    defer tn.deinit();

    // BCC 0x200 + 0x14 is 0x214 
    // This instruction will jump back 22 
    // (0xea is minus 0x14)
    tn.writeBytes(0x214, &[_]u8{0x90, 0xea});

    tn.cpu.setFlag(.Carry, true);
    // 2 since jump failed
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.pc, 0x203);

    // 3 since jump needed
    tn.cpu.setFlag(.Carry, false);
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.pc, 0x215);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.pc, 0x201);
}

pub fn bcsTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator,
    &[_]u8{
        0xB0, 0x12, // BCS #$12 -- fall through
        0xB0, 0x10, // BCS #$10 -- jump PC + 16 
    });
    defer tn.deinit();

    // BCS 0x200 + 0x14 is 0x214 
    // This instruction will jump back 22 
    // (0xea is minus 0x14)
    tn.writeBytes(0x214, &[_]u8{0xB0, 0xea});

    tn.cpu.setFlag(.Carry, false);
    // 2 since jump failed
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.pc, 0x203);

    // 3 since jump needed
    tn.cpu.setFlag(.Carry, true);
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.pc, 0x215);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.pc, 0x201);

}

pub fn bvcTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator,
    &[_]u8{
        0x50, 0x12, // BVC #$12 -- fall through
        0x50, 0x10, // BVC #$10 -- jump PC + 16 
    });
    defer tn.deinit();

    // BVC 0x200 + 0x14 is 0x214 
    // This instruction will jump back 22 
    // (0xea is minus 0x14)
    tn.writeBytes(0x214, &[_]u8{0x50, 0xea});

    tn.cpu.setFlag(.Overflow, true);
    // 2 since jump failed
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.pc, 0x203);

    // 3 since jump needed
    tn.cpu.setFlag(.Overflow, false);
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.pc, 0x215);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.pc, 0x201);
}

pub fn bvsTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator,
    &[_]u8{
        0x70, 0x12, // BVS #$12 -- fall through
        0x70, 0x10, // BVS #$10 -- jump PC + 16 
    });
    defer tn.deinit();

    // BVS 0x200 + 0x14 is 0x214 
    // This instruction will jump back 22 
    // (0xea is minus 0x14)
    tn.writeBytes(0x214, &[_]u8{0x70, 0xea});

    tn.cpu.setFlag(.Overflow, false);
    // 2 since jump failed
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.pc, 0x203);

    // 3 since jump needed
    tn.cpu.setFlag(.Overflow, true);
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.pc, 0x215);

    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.cpu.pc, 0x201);
}

pub fn skip_jmpTest() !void {

}

pub fn skip_jsrTest() !void {

}

pub fn skip_interruptTest() !void {

}

