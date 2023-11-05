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
