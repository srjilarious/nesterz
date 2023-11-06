const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");

test "AND Immediate" {
    var tn = try fix.TestNes.initWithTesData(&std.testing.allocator, &[_]u8{
        0x29, 0xfb, // AND #$fb
        0x29, 0xab, // AND #$ab
        0x29, 0x22, // AND #$22
    });
    defer tn.deinit();

    tn.cpu.a = 0xff;

    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0xfb);
    // TODO Add flag checks.

    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0xab);

    try std.testing.expectEqual(try tn.tickInstruction(), 2);
    try std.testing.expectEqual(tn.cpu.a, 0x22);
}

test "AND ZeroPage" {
    var tn = try fix.TestNes.initWithTesData(&std.testing.allocator, &[_]u8{
        0x25, 0x10, // AND $10
        0x25, 0x11, // AND $11
        0x25, 0x12, // AND $12
    });
    defer tn.deinit();

    tn.writeBytes(0x10, &[_]u8{ 0xfb, 0xab, 0x22 });

    tn.cpu.a = 0xff;

    try std.testing.expectEqual(try tn.tickInstruction(), 3);
    try std.testing.expectEqual(tn.cpu.a, 0xfb);
    // TODO Add flag checks.

    try std.testing.expectEqual(try tn.tickInstruction(), 3);
    try std.testing.expectEqual(tn.cpu.a, 0xab);

    try std.testing.expectEqual(try tn.tickInstruction(), 3);
    try std.testing.expectEqual(tn.cpu.a, 0x22);
}
