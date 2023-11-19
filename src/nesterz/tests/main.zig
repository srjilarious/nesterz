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

const Red = "\x1b[91m";
const Green = "\x1b[92m";
const Blue = "\x1b[94m";
const Cyan = "\x1b[96m";
const White = "\x1b[97m";

const Reset = "\x1b[0m";

pub fn main() !void {
    std.debug.print("\nRunning unit tests:\n", .{});
    var testsRun: u32 = 0;
    var testsPassed: u32 = 0;
    var testsFailed: u32 = 0;
    for (Tests) |f| {
        testsRun += 1;
        const res = f();
        if (res != error.TestExpectedEqual) {
            testsPassed += 1;
            std.debug.print(Blue ++ ".", .{});
        } else {
            testsFailed += 1;
            std.debug.print(Red ++ "X", .{});
        }
    }
    std.debug.print(Green ++ "\nDone!\n\n" ++ Reset, .{});
    std.debug.print(White ++ "{} " ++ Green ++ "Passed" ++ Reset ++ ", " ++
        White ++ "{} " ++ Red ++ "Failed" ++ Reset ++ ", " ++
        White ++ "{} " ++ Cyan ++ "Total Tests" ++ Reset, .{ testsPassed, testsFailed, testsRun });
}
