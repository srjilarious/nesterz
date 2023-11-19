const std = @import("std");

const Red = "\x1b[91m";
const Green = "\x1b[92m";
const Blue = "\x1b[94m";
const Cyan = "\x1b[96m";
const White = "\x1b[97m";

const Reset = "\x1b[0m";

pub const TestFunc = *const fn () error{TestExpectedEqual}!void;
pub const TestFuncInfo = struct { func: TestFunc, name: []const u8 };

pub fn discoverTestsInModule(comptime mod: type) []TestFuncInfo {

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

    comptime var tests: [numTests]TestFuncInfo = undefined;
    var idx: usize = 0;
    for (std.meta.declarations(mod)) |decl| {
        const fld = @field(mod, decl.name);
        const ti = @typeInfo(@TypeOf(fld));
        if (ti == .Fn) {
            if (std.mem.endsWith(u8, decl.name, "Test")) {
                // @compileLog("Adding TEST: " ++ decl.name);
                tests[idx] = .{ .func = fld, .name = decl.name };
                idx += 1;
            }
        }
    }

    return &tests;
    // @compileLog(tests);
}

pub fn discoverTests(comptime mods: anytype) []TestFuncInfo {
    const ModsType = @TypeOf(mods);
    const modsTypeInfo = @typeInfo(ModsType);
    if (modsTypeInfo != .Struct) {
        @compileError("expected tuple or struct argument of modules, found " ++ @typeName(ModsType));
    }

    const fieldsInfo = modsTypeInfo.Struct.fields;
    const MaxTests = 10000;
    comptime var tests: [MaxTests]TestFuncInfo = undefined;
    comptime var totalTests: usize = 0;
    var fieldIdx = 0;
    inline for (fieldsInfo) |_| {
        const fieldName = std.fmt.comptimePrint("{}", .{fieldIdx});
        fieldIdx += 1;
        const currMod = @field(mods, fieldName);
        const modTests = discoverTestsInModule(currMod);
        for (modTests) |t| {
            tests[totalTests] = t;
            totalTests += 1;
        }
    }

    return tests[0..totalTests];
}

pub fn runTests(tests: []TestFuncInfo, verbose: bool) void {
    if (verbose) std.debug.print("\nRunning tests:\n", .{});
    var testsRun: u32 = 0;
    var testsPassed: u32 = 0;
    var testsFailed: u32 = 0;
    for (tests) |f| {
        testsRun += 1;

        if (verbose) {
            std.debug.print("\nRunning " ++ White ++ "{s}" ++ Reset ++ "..", .{f.name});
        }
        const res = f.func();
        if (res != error.TestExpectedEqual) {
            testsPassed += 1;

            if (verbose) {
                std.debug.print(Blue ++ "\u{2713}" ++ Reset, .{});
            } else {
                std.debug.print(Blue ++ "." ++ Reset, .{});
            }
        } else {
            testsFailed += 1;
            std.debug.print(Red ++ "X" ++ Reset, .{});
        }
    }

    //std.debug.print(Green ++ "\nDone!\n\n" ++ Reset, .{});
    std.debug.print("\n" ++ White ++ "{} " ++ Green ++ "Passed" ++ Reset ++ ", " ++
        White ++ "{} " ++ Red ++ "Failed" ++ Reset ++ ", " ++
        White ++ "{} " ++ Cyan ++ "Total Tests" ++ Reset ++ "\n\n", .{ testsPassed, testsFailed, testsRun });
}
