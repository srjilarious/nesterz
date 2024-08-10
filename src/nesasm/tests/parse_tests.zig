const std = @import("std");
const nesasm = @import("nesasm");
const testz = @import("testz");

pub fn removeCommentTests() !void {
    const noComment = nesasm.utils.removeComment("   ADC $10");
    try testz.expectEqualStr(noComment, "   ADC $10");

    const noComment2 = nesasm.utils.removeComment("CDC");
    try testz.expectEqualStr(noComment2, "CDC");

    const comment = nesasm.utils.removeComment("   CDC ; my comment");
    try testz.expectEqualStr(comment, "   CDC ");

    const comment2 = nesasm.utils.removeComment(";   CDC ; my comment");
    try testz.expectEqualStr(comment2, "");
}

// pub fn parseLineTokensTest() !void {
//     var tokens = std.mem.tokenize(u8, "   CDC $10", " \t");
//     while (tokens.next()) |token| {
//         std.debug.print("'{s}', ", .{token});
//     }
// }
