const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

pub fn transferXTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xAA, // TAX
        0x8A, // TXA
        0xAA, // TAX
        0x8A, // TXA
    });
    defer tn.deinit();

    tn.cpu.a = 0x10;
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x10);
    try testz.expectEqual(tn.cpu.x, 0x10);

    tn.cpu.x = 0x50;
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x50);
    try testz.expectEqual(tn.cpu.x, 0x50);

    tn.cpu.a = 0xff;
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0xff);
    try testz.expectEqual(tn.cpu.x, 0xff);

    tn.cpu.x = 0x0;
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.x, 0x0);
}

pub fn skip_transferYTest() !void {}
pub fn skip_transferSPTest() !void {}
