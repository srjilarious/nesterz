const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

pub fn pushPullAccumulatorTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x48, // PHA
        0x69, 0x10, // ADC #$10 - Add 0x10 to acc
        0x48, // PHA
        0x69, 0x10, // ADC #$10 - Add 0x10 to acc
        0x68, // PLA
        0x68, // PLA
    });

    defer tn.deinit();

    tn.cpu.a = 0x45;
    try testz.expectEqual(tn.cpu.sp, 0);
    try testz.expectEqual(tn.readByte(0x100), 0x0);

    // First PHA, should push 0x45 to stack
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.readByte(0x100), 0x45);
    try testz.expectEqual(tn.cpu.sp, 1);

    // Add 0x10 to accumulator
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x55);

    // Second PHA, should push 0x45 to stack
    try testz.expectEqual(tn.tickInstruction(), 3);
    try testz.expectEqual(tn.readByte(0x101), 0x55);
    try testz.expectEqual(tn.cpu.sp, 2);

    // Add 0x10 to accumulator
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x65);

    // First PLA, should pull 0x55 from stack
    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x55);
    try testz.expectEqual(tn.cpu.sp, 1);

    // Second PLA, should pull 0x45 from stack
    try testz.expectEqual(tn.tickInstruction(), 4);
    try testz.expectEqual(tn.cpu.a, 0x45);
    try testz.expectEqual(tn.cpu.sp, 0);
}

pub fn skip_pushPullProcStatusTest() !void {}
