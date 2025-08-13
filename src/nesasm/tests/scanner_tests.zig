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

pub fn scan_base10_num() !void {
    var scanner = Scanner.init(std.heap.page_allocator, "123");
    const tokens = scanner.scan();

    try testz.expectEqual(tokens.items.len, 2);
    try testz.expectEqual(tokens.items[0].type, TokenType.Number);
    try testz.expectEqual(tokens.items[0].value.number, 123);
    try testz.expectEqual(tokens.items[1].type, TokenType.Eof);
}

pub fn scan_base16_num() !void {
    var scanner = Scanner.init(std.heap.page_allocator, "$20");
    const tokens = scanner.scan();

    try testz.expectEqual(tokens.items.len, 2);
    try testz.expectEqual(tokens.items[0].type, TokenType.Number);
    try testz.expectEqual(tokens.items[0].value.number, 32);
    try testz.expectEqual(tokens.items[1].type, TokenType.Eof);
}

pub fn scan_base16_num_lines() !void {
    var scanner = Scanner.init(std.heap.page_allocator, "$20\n$40\n$ff");
    const tokens = scanner.scan();

    try testz.expectEqual(tokens.items.len, 6);
    try testz.expectEqual(tokens.items[0].type, TokenType.Number);
    try testz.expectEqual(tokens.items[0].value.number, 32);
    try testz.expectEqual(tokens.items[1].type, TokenType.NewLine);

    try testz.expectEqual(tokens.items[2].type, TokenType.Number);
    try testz.expectEqual(tokens.items[2].value.number, 64);
    try testz.expectEqual(tokens.items[3].type, TokenType.NewLine);

    try testz.expectEqual(tokens.items[4].type, TokenType.Number);
    try testz.expectEqual(tokens.items[4].value.number, 255);
    try testz.expectEqual(tokens.items[5].type, TokenType.Eof);
}
