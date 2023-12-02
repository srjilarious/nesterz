const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("./test_runner.zig");

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
