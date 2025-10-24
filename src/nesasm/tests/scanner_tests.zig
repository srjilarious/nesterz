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

pub fn scanBase16Num_2() !void {
    var scanner = Scanner.init(std.heap.page_allocator, "$1fa2");
    const tokens = scanner.scan();

    try testz.expectEqual(tokens.items.len, 2);
    try testz.expectEqual(tokens.items[0].type, .Number);
    try testz.expectEqual(tokens.items[0].value.number, 0x1fa2);
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

pub fn scanSymbol() !void {
    var scanner = Scanner.init(std.heap.page_allocator, "var  = $ff ; A fancy variable.");
    const tokens = scanner.scan();

    try testz.expectEqual(tokens.items.len, 4);
    try testz.expectEqual(tokens.items[0].type, .Identifier);
    try testz.expectEqualStr(tokens.items[0].value.string, "var");

    try testz.expectEqual(tokens.items[1].type, .Equal);

    try testz.expectEqual(tokens.items[2].type, .Number);
    try testz.expectEqual(tokens.items[2].value.number, 255);

    try testz.expectEqual(tokens.items[3].type, .Eof);
}

pub fn scanIteratorTest() !void {
    var scanner = Scanner.init(std.heap.page_allocator, "LDA #$20\nSTA $2000");
    _ = scanner.scan();
    var iter = scanner.iterator();

    var token = iter.next();
    try testz.expectEqual(token.?.type, .Identifier);
    try testz.expectEqualStr(token.?.value.string, "LDA");

    // Check peek
    try testz.expectEqual(iter.peek().?.type, .Pound);
    token = iter.next();

    try testz.expectEqual(token.?.type, .Pound);

    token = iter.next();
    try testz.expectEqual(token.?.type, .Number);
    try testz.expectEqual(token.?.value.number, 32);

    token = iter.next();
    try testz.expectEqual(token.?.type, .NewLine);

    token = iter.next();
    try testz.expectEqual(token.?.type, .Identifier);
    try testz.expectEqualStr(token.?.value.string, "STA");

    // Check peek again.
    try testz.expectEqual(iter.peek().?.type, .Number);

    token = iter.next();
    try testz.expectEqual(token.?.type, .Number);
    try testz.expectEqual(token.?.value.number, 8192); // $2000 in decimal

    token = iter.next();
    try testz.expectEqual(token.?.type, .Eof); // End of file
    try testz.expectTrue(iter.isEof());

    token = iter.next();
    try testz.expectEqual(token, null); // End of tokens
    try testz.expectTrue(iter.isEof());
}

pub fn scanIndirectXTest() !void {
    var scanner = Scanner.init(std.heap.page_allocator, "ADC ($10,X)");
    _ = scanner.scan();
    var iter = scanner.iterator();

    var token = iter.next();
    try testz.expectEqual(token.?.type, .Identifier);
    try testz.expectEqualStr(token.?.value.string, "ADC");

    token = iter.next();
    try testz.expectEqual(token.?.type, .LeftParen);

    token = iter.next();
    try testz.expectEqual(token.?.type, .Number);
    try testz.expectEqual(token.?.value.number, 16);

    token = iter.next();
    try testz.expectEqual(token.?.type, .Comma);

    token = iter.next();
    try testz.expectEqual(token.?.type, .Identifier);
    try testz.expectEqualStr(token.?.value.string, "X");

    token = iter.next();
    try testz.expectEqual(token.?.type, .RightParen);

    token = iter.next();
    try testz.expectEqual(token.?.type, .Eof);
}
