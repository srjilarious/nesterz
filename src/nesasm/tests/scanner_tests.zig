const std = @import("std");
const testz = @import("testz");
const nes = @import("nesterz");
const nasm = @import("nesasm");

const Scanner = nasm.scanner.Scanner;
const TokenType = nasm.scanner.TokenType;

pub fn scan_test1() !void {
    var scanner = Scanner.init(std.heap.page_allocator, "#()\n");
    const tokens = scanner.scan();

    try testz.expectEqual(tokens.items.len, 5);
    try testz.expectEqual(tokens.items[0].type, TokenType.Pound);
    try testz.expectEqual(tokens.items[1].type, TokenType.LeftParen);
    try testz.expectEqual(tokens.items[2].type, TokenType.RightParen);
    try testz.expectEqual(tokens.items[3].type, TokenType.NewLine);
    try testz.expectEqual(tokens.items[4].type, TokenType.Eof);
}
