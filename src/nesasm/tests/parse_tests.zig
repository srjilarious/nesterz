const std = @import("std");
const nesasm = @import("nesasm");
const nes = @import("nesterz");
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

pub fn checkAdcAssembleParse() !void {
    var assembler = try nesasm.Assembler6502.init(std.heap.page_allocator);
    const alOpt = try assembler.parseLine("  ADC $10 ; Testing");

    try testz.expectNotEqual(alOpt, null);
    const al = alOpt.?;

    try testz.expectEqual(al.instr.?.op, nes.CpuOp.ADC);
}

// pub fn parseLineTokensTest() !void {
//     var tokens = std.mem.tokenize(u8, "   CDC $10", " \t");
//     while (tokens.next()) |token| {
//         std.debug.print("'{s}', ", .{token});
//     }
// }
