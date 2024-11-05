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

pub fn checkOperandParsingHex() !void {
    const val = try nesasm.assembler.parseOperand("$ff");
    try testz.expectEqual(val.byte, 0xff);

    const word = try nesasm.assembler.parseOperand("$3a10");
    try testz.expectEqual(word.word, 0x3a10);
}

pub fn checkOperandParsing_u8() !void {
    var val = try nesasm.assembler.parseOperand("0");
    try testz.expectEqual(val.byte, 0);

    val = try nesasm.assembler.parseOperand("-1");
    try testz.expectEqual(val.byte, 0xff);
    try testz.expectEqual(@as(i8, @bitCast(val.byte)), -1);

    val = try nesasm.assembler.parseOperand("-128");
    try testz.expectEqual(val.byte, 0x80);
    try testz.expectEqual(@as(i8, @bitCast(val.byte)), -128);

    val = try nesasm.assembler.parseOperand("255");
    try testz.expectEqual(val.byte, 0xff);

    val = try nesasm.assembler.parseOperand("127");
    try testz.expectEqual(val.byte, 0x7f);
}

pub fn checkOperandParsing_u16() !void {
    var val = try nesasm.assembler.parseOperand("-129");
    try testz.expectEqual(val.word, 0xff7f);
    try testz.expectEqual(@as(i16, @bitCast(val.word)), -129);

    val = try nesasm.assembler.parseOperand("-32768");
    try testz.expectEqual(val.word, 0x8000);
    try testz.expectEqual(@as(i16, @bitCast(val.word)), -32768);

    val = try nesasm.assembler.parseOperand("65535");
    try testz.expectEqual(val.word, 0xffff);

    val = try nesasm.assembler.parseOperand("32767");
    try testz.expectEqual(val.word, 0x7fff);

    val = try nesasm.assembler.parseOperand("256");
    try testz.expectEqual(val.word, 0x100);
}

pub fn testParseImmediateModeAddrOperand() !void {
    var tokens = std.mem.tokenizeAny(u8, "#$ff", " \t");
    const val = try nesasm.assembler.parseAddrAndOperand(.AND, &tokens);
    try testz.expectEqual(val.?.addr, .Immediate);
    try testz.expectEqual(val.?.operand.?.byte, 0xff);
}

pub fn testParseAccumulatorModeAddrOperand() !void {
    var tokens = std.mem.tokenizeAny(u8, "A", " \t");
    const val = try nesasm.assembler.parseAddrAndOperand(.ASL, &tokens);
    try testz.expectEqual(val.?.addr, .Accumulator);
    try testz.expectEqual(val.?.operand, null);
}

// pub fn parseLineTokensTest() !void {
//     var tokens = std.mem.tokenize(u8, "   CDC $10", " \t");
//     while (tokens.next()) |token| {
//         std.debug.print("'{s}', ", .{token});
//     }
// }
