const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

pub fn jmpAbsoluteTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x4C, 0x00, 0xFF, // JMP $ff00 - Jump to 0xFF00
        0xEA, // NOP
    });

    // Jump back to original address.
    tn.writeBytes(0xff00, &[_]u8{
        0x4C, 0x00, 0x02, // JMP $200
        0xEA, // NOP
    });
    defer tn.deinit();

    try testz.expectEqual(tn.cpu.pc, 0x201);
    try testz.expectEqual(tn.tickInstruction(), 3);

    try testz.expectEqual(tn.cpu.pc, 0xff01);
    try testz.expectEqual(tn.tickInstruction(), 3);

    try testz.expectEqual(tn.cpu.pc, 0x201);
    try testz.expectEqual(tn.tickInstruction(), 3);
}

pub fn jmpIndirectTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x6C, 0x10, 0x20, // JMP ($2010) - Jump indirectly to 0xFF00
        0xEA,
    });

    // Write address in memory
    tn.writeBytes(0x2010, &[_]u8{ 0x00, 0xff });

    // Jump back to original address.
    tn.writeBytes(0xff00, &[_]u8{
        0xEA, // NOP
    });
    defer tn.deinit();

    try testz.expectEqual(tn.cpu.pc, 0x201);
    try testz.expectEqual(tn.tickInstruction(), 5);

    try testz.expectEqual(tn.cpu.pc, 0xff01);
}

pub fn jsrAbsoluteTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x20, 0x00, 0xFF, // JSR $ff00 - Jump to subroutine at 0xFF00
        0xC6, 0x10, // INC $10 - Increment value at ZP 0x10
    });

    defer tn.deinit();

    // Sub routine that increments y by 2, and x by 1
    tn.writeBytes(0xff00, &[_]u8{
        0xC8, // INY
        0xC8, // INY
        0xE8, // INX
        0x60, // RTS
    });

    tn.cpu.status = 0xcd;

    try testz.expectEqual(tn.cpu.sp, 0);

    // JSR takes 6 instructions
    try testz.expectEqual(tn.tickInstruction(), 6);

    try testz.expectEqual(tn.cpu.sp, 253);

    // Run the first INY
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.y, 1);

    // Run the second INY
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.y, 2);

    // Run the INX
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.x, 1);

    // Force a dummy status value
    tn.cpu.status = 0;

    // RTS takes 6 instructions
    try testz.expectEqual(tn.tickInstruction(), 6);
    try testz.expectEqual(tn.cpu.sp, 0);
    try testz.expectEqual(tn.cpu.status, 0xcd);
}

pub fn skip_rtiImpliedTest() !void {}
