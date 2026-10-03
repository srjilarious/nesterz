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
    try testz.expectFalse(tn.cpu.getFlag(.Zero));
    try testz.expectFalse(tn.cpu.getFlag(.Negative));
    try testz.expectEqual(tn.cpu.a, 0x10);
    try testz.expectEqual(tn.cpu.x, 0x10);

    tn.cpu.x = 0x50;
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectFalse(tn.cpu.getFlag(.Zero));
    try testz.expectFalse(tn.cpu.getFlag(.Negative));
    try testz.expectEqual(tn.cpu.a, 0x50);
    try testz.expectEqual(tn.cpu.x, 0x50);

    tn.cpu.a = 0xff;
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectFalse(tn.cpu.getFlag(.Zero));
    try testz.expectTrue(tn.cpu.getFlag(.Negative));
    try testz.expectEqual(tn.cpu.a, 0xff);
    try testz.expectEqual(tn.cpu.x, 0xff);

    tn.cpu.x = 0x0;
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectTrue(tn.cpu.getFlag(.Zero));
    try testz.expectFalse(tn.cpu.getFlag(.Negative));

    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.x, 0x0);
}

pub fn transferYTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xA8, // TAY
        0x98, // TYA
        0xA8, // TAY
        0x98, // TYA
    });
    defer tn.deinit();

    tn.cpu.a = 0x10;
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x10);
    try testz.expectEqual(tn.cpu.y, 0x10);

    tn.cpu.y = 0x50;
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x50);
    try testz.expectEqual(tn.cpu.y, 0x50);

    tn.cpu.a = 0xff;
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0xff);
    try testz.expectEqual(tn.cpu.y, 0xff);

    tn.cpu.y = 0x0;
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.a, 0x0);
    try testz.expectEqual(tn.cpu.y, 0x0);
}

pub fn transferSPTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0xBA, // TSX
        0x9A, // TXS
        0xBA, // TSX
        0x9A, // TXS
    });
    defer tn.deinit();

    tn.cpu.sp = 0x10;
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.sp, 0x10);
    try testz.expectEqual(tn.cpu.x, 0x10);

    tn.cpu.x = 0x50;
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.sp, 0x50);
    try testz.expectEqual(tn.cpu.x, 0x50);

    tn.cpu.sp = 0xff;
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.sp, 0xff);
    try testz.expectEqual(tn.cpu.x, 0xff);

    tn.cpu.x = 0x0;
    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.sp, 0x0);
    try testz.expectEqual(tn.cpu.x, 0x0);
}
