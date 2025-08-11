const std = @import("std");

const ErrorContext = struct {
    hadError: bool = false,
};

var errContext: ErrorContext = .{};

pub fn err(line: u32, message: []const u8) void {
    report(line, "", message);
}

pub fn report(line: u32, where: []const u8, message: []const u8) void {
    std.debug.print("{s}[{}]: {s}\n", .{ where, line, message });
    errContext.hadError = true;
}
