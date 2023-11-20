// zig fmt: off
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

pub const TestFailure = struct { 
    //testName: [256]u8, 
    lineNo: usize, 
    errorMessage: []u8,
};

pub const TestContext = struct { 
    failures: std.ArrayList(TestFailure),
    alloc: std.mem.Allocator,

    fn init(alloc: std.mem.Allocator) TestContext {
        return .{
            .failures = std.ArrayList(TestFailure).init(alloc),
            .alloc = alloc
        };
    }

    fn deinit(self: *TestContext) void {
        for(self.failures) |fail| {
            self.alloc.free(fail.errorMessage);
        }
        self.alloc.free(self.failures);
    }

    fn expectEqual(self: *TestContext, expected: anytype, actual: anytype) !void {
        if(expected != actual) {
            var fail: TestFailure = .{
                .lineNo = 123,
                .errorMessage = undefined
            };
            // fail.errorMessage = "";
            fail.errorMessage = std.fmt.allocPrint(self.alloc, 
                Red ++ "FAIL" ++ Reset ++ ": Expected " ++ White ++ "{}" ++ Reset ++ " == " ++ White ++ "{}" ++ Reset, 
                .{expected, actual}) catch {
                @panic("OOM");
            };

            self.failures.append(fail) catch {
                @panic("Unable to Append, OOM.");
            };
            
            std.debug.dumpCurrentStackTrace(null);
            return error.TestExpectedEqual;
        }
    }
};

var GlobalTestContext: ?TestContext = null;//TestContext.init();

pub fn expectEqual(expected: anytype, actual: anytype) !void {
    try GlobalTestContext.?.expectEqual(expected, actual);
}

pub fn runTests(tests: []TestFuncInfo, verbose: bool) void {
    GlobalTestContext = TestContext.init(std.heap.page_allocator);

    if (verbose) std.debug.print("\nRunning tests:\n", .{});
    var testsRun: u32 = 0;
    var testsPassed: u32 = 0;
    var testsFailed: u32 = 0;

    // Find the longest length name in the tests for formatting.
    var verboseLength: usize = 0;
    if (verbose) {
        for (tests) |f| {
            if (f.name.len > verboseLength) {
                verboseLength = f.name.len;
            }
        }
    }

    // Run each of the tests.
    for (tests) |f| {
        testsRun += 1;

        if (verbose) {
            std.debug.print("\nRunning " ++ White ++ "{s}" ++ Reset ++ "...", .{f.name});
            var num = @min(verboseLength - f.name.len, 128);
            while (num > 0) {
                std.debug.print(".", .{});
                num -= 1;
            }
        }

        const res = f.func();
        if (res != error.TestExpectedEqual) {
            testsPassed += 1;

            if (verbose) {
                std.debug.print(Green ++ "\u{2713}" ++ Reset, .{});
            } else {
                std.debug.print(Green ++ "." ++ Reset, .{});
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


    // Testing
    for(GlobalTestContext.?.failures.items) |fail| {
        std.debug.print("{s}\n", .{fail.errorMessage});
    }
}
