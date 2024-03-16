const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

pub fn flagClearSetTest() !void {
    var tn = fix.TestNes.initWithTesData(&std.heap.page_allocator, &[_]u8{
        0x38, // SEC
        0x78, // SEI
        0x18, // CLC
        0x58, // CLI
        0xB8, // CLV
    });
    defer tn.deinit();

    // Start with the overflow flag set.
    tn.cpu.setFlag(.Overflow, true);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), false);
    try testz.expectEqual(tn.cpu.getFlag(.InterruptsDisabled), false);
    try testz.expectEqual(tn.cpu.getFlag(.Overflow), true);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);
    try testz.expectEqual(tn.cpu.getFlag(.InterruptsDisabled), false);
    try testz.expectEqual(tn.cpu.getFlag(.Overflow), true);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), true);
    try testz.expectEqual(tn.cpu.getFlag(.InterruptsDisabled), true);
    try testz.expectEqual(tn.cpu.getFlag(.Overflow), true);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), false);
    try testz.expectEqual(tn.cpu.getFlag(.InterruptsDisabled), true);
    try testz.expectEqual(tn.cpu.getFlag(.Overflow), true);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), false);
    try testz.expectEqual(tn.cpu.getFlag(.InterruptsDisabled), false);
    try testz.expectEqual(tn.cpu.getFlag(.Overflow), true);

    try testz.expectEqual(tn.tickInstruction(), 2);
    try testz.expectEqual(tn.cpu.getFlag(.Carry), false);
    try testz.expectEqual(tn.cpu.getFlag(.InterruptsDisabled), false);
    try testz.expectEqual(tn.cpu.getFlag(.Overflow), false);
}
