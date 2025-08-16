const std = @import("std");
const testz = @import("testz");
const nes = @import("nesterz");
const nasm = @import("nesasm");

const Scanner = nasm.scanner.Scanner;
const TokenType = nasm.scanner.TokenType;

pub fn scanTest1() !void {
    var scanner = Scanner.init(std.heap.page_allocator, "#()\n");
    const tokens = scanner.scan();

    try testz.expectEqual(tokens.items.len, 5);
    try testz.expectEqual(tokens.items[0].type, .Pound);
    try testz.expectEqual(tokens.items[1].type, .LeftParen);
    try testz.expectEqual(tokens.items[2].type, .RightParen);
    try testz.expectEqual(tokens.items[3].type, .NewLine);
    try testz.expectEqual(tokens.items[4].type, .Eof);
}

pub fn scanBase10Num() !void {
    var scanner = Scanner.init(std.heap.page_allocator, "123");
    const tokens = scanner.scan();

    try testz.expectEqual(tokens.items.len, 2);
    try testz.expectEqual(tokens.items[0].type, .Number);
    try testz.expectEqual(tokens.items[0].value.number, 123);
    try testz.expectEqual(tokens.items[1].type, .Eof);
}

pub fn scanBase16Num() !void {
    var scanner = Scanner.init(std.heap.page_allocator, "$20");
    const tokens = scanner.scan();

    try testz.expectEqual(tokens.items.len, 2);
    try testz.expectEqual(tokens.items[0].type, .Number);
    try testz.expectEqual(tokens.items[0].value.number, 32);
    try testz.expectEqual(tokens.items[1].type, .Eof);
}

pub fn scanBase16NumLines() !void {
    var scanner = Scanner.init(std.heap.page_allocator, "$20\n$40\n$ff");
    const tokens = scanner.scan();

    try testz.expectEqual(tokens.items.len, 6);
    try testz.expectEqual(tokens.items[0].type, .Number);
    try testz.expectEqual(tokens.items[0].value.number, 32);
    try testz.expectEqual(tokens.items[1].type, .NewLine);

    try testz.expectEqual(tokens.items[2].type, .Number);
    try testz.expectEqual(tokens.items[2].value.number, 64);
    try testz.expectEqual(tokens.items[3].type, .NewLine);

    try testz.expectEqual(tokens.items[4].type, .Number);
    try testz.expectEqual(tokens.items[4].value.number, 255);
    try testz.expectEqual(tokens.items[5].type, .Eof);
}

pub fn scanIdentifier() !void {
    var scanner = Scanner.init(std.heap.page_allocator, "ADC");
    const tokens = scanner.scan();

    try testz.expectEqual(tokens.items.len, 2);
    try testz.expectEqual(tokens.items[0].type, .Identifier);
    try testz.expectEqualStr(tokens.items[0].value.string, "ADC");
    try testz.expectEqual(tokens.items[1].type, .Eof);
}

pub fn scanLabel() !void {
    var scanner = Scanner.init(std.heap.page_allocator, "test:");
    const tokens = scanner.scan();

    try testz.expectEqual(tokens.items.len, 3);
    try testz.expectEqual(tokens.items[0].type, .Identifier);
    try testz.expectEqualStr(tokens.items[0].value.string, "test");
    try testz.expectEqual(tokens.items[1].type, .Colon);
    try testz.expectEqual(tokens.items[2].type, .Eof);
}

pub fn scanLabelAndComment() !void {
    var scanner = Scanner.init(std.heap.page_allocator, "test: ; Start doing a thing");
    const tokens = scanner.scan();

    try testz.expectEqual(tokens.items.len, 3);
    try testz.expectEqual(tokens.items[0].type, .Identifier);
    try testz.expectEqualStr(tokens.items[0].value.string, "test");
    try testz.expectEqual(tokens.items[1].type, .Colon);
    try testz.expectEqual(tokens.items[2].type, .Eof);
}
