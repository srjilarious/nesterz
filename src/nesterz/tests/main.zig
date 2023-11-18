const std = @import("std");
const adc = @import("./adc_inst.zig");

comptime {
    _ = @import("./cpu.zig");
    _ = @import("./and_inst.zig");
    _ = @import("./asl_inst.zig");
    _ = @import("./lsr_inst.zig");
    _ = @import("./ora_inst.zig");
    _ = @import("./incdec_inst.zig");
}

const Tests = adc.Tests;
pub fn main() !void {
    std.debug.print("\nRunning unit tests:\n", .{});
    for (Tests) |f| {
        const res = f();
        if (res != error.TestExpectedEqual) {
            std.debug.print(".", .{});
        } else {
            std.debug.print("X", .{});
        }
    }
    std.debug.print("\nDone!\n\n", .{});
}
