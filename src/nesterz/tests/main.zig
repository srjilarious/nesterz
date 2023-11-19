const std = @import("std");
const adcTests = @import("./adc_inst.zig");
const andTests = @import("./and_inst.zig");
const fix = @import("./fixtures.zig");

comptime {
    _ = @import("./cpu.zig");
    _ = @import("./asl_inst.zig");
    _ = @import("./lsr_inst.zig");
    _ = @import("./ora_inst.zig");
    _ = @import("./incdec_inst.zig");
}

const Red = "\x1b[91m";
const Green = "\x1b[92m";
const Blue = "\x1b[94m";
const Cyan = "\x1b[96m";
const White = "\x1b[97m";

const Reset = "\x1b[0m";

pub fn discoverTestsInModule(comptime mod: type) []fix.TestFunc {
    // @compileLog(@typeInfo(andTests).Struct.decls);
    var numTests: usize = 0;
    for (std.meta.declarations(mod)) |decl| {
        const fld = @field(mod, decl.name);
        const ti = @typeInfo(@TypeOf(fld));
        if (ti == .Fn) {
            if (std.mem.endsWith(u8, decl.name, "Test")) {
                numTests += 1;
                // @compileLog("Found TEST: ", numTests);
            }
        }
    }

    comptime var tests: [numTests]fix.TestFunc = undefined;
    var idx: usize = 0;
    for (std.meta.declarations(mod)) |decl| {
        const fld = @field(mod, decl.name);
        const ti = @typeInfo(@TypeOf(fld));
        if (ti == .Fn) {
            if (std.mem.endsWith(u8, decl.name, "Test")) {
                // @compileLog("Adding TEST: " ++ decl.name);
                tests[idx] = fld;
                idx += 1;
            }
        }
    }

    return &tests;
    // @compileLog(tests);
}

const Tests = discoverTestsInModule(adcTests) ++
    discoverTestsInModule(andTests);

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
        White ++ "{} " ++ Cyan ++ "Total Tests" ++ Reset ++ "\n\n", .{ testsPassed, testsFailed, testsRun });
}
