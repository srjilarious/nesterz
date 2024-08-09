const std = @import("std");

pub fn removeComment(line: []const u8) []const u8 {
    const semiLoc = std.mem.indexOf(u8, line, ";");
    if (semiLoc != null) {
        return line[0..semiLoc.?];
    }

    // No comment, so return line as is
    return line;
}
