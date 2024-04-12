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

pub fn skip_bmiTest() !void {

}

pub fn skip_beqTest() !void {

}

pub fn skip_bneTest() !void {

}

pub fn skip_bccTest() !void {

}

pub fn skip_bcsTest() !void {

}

pub fn skip_bvcTest() !void {

}

pub fn skip_bvsTest() !void {

}

