const std = @import("std");
const testz = @import("testz");
const nes = @import("nesterz");
const nasm = @import("nesasm");

const CpuOp = nes.CpuOp;
const AddressMode = nes.AddressMode;
const Operand = nasm.Operand;

fn checkCodeGen(op: CpuOp, addr: AddressMode, operand: ?Operand, expected: []const u8) !void {
    // Buffer for storing generated instruction.
    var buff: [4]u8 = .{0} ** 4;
    const result = nasm.codeGen(op, .{ .addr = addr, .operand = operand }, &buff);
    try testz.expectEqualStr(result.?, expected);
}

pub fn genImpliedInstructions() !void {
    try checkCodeGen(.BRK, .Implied, null, &[_]u8{0x0});
    try checkCodeGen(.CLC, .Implied, null, &[_]u8{0x18});
    try checkCodeGen(.CLI, .Implied, null, &[_]u8{0x58});
    try checkCodeGen(.CLV, .Implied, null, &[_]u8{0xB8});
    try checkCodeGen(.DEX, .Implied, null, &[_]u8{0xCA});
    try checkCodeGen(.DEY, .Implied, null, &[_]u8{0x88});
    try checkCodeGen(.INX, .Implied, null, &[_]u8{0xE8});
    try checkCodeGen(.INY, .Implied, null, &[_]u8{0xC8});
    // try checkCodeGen(.NOP, .Implied, null, &[_]u8{0xEA});
    try checkCodeGen(.PHA, .Implied, null, &[_]u8{0x48});
    try checkCodeGen(.PHP, .Implied, null, &[_]u8{0x08});
    try checkCodeGen(.PLA, .Implied, null, &[_]u8{0x68});
    try checkCodeGen(.PLP, .Implied, null, &[_]u8{0x28});
    try checkCodeGen(.SEC, .Implied, null, &[_]u8{0x38});
    try checkCodeGen(.SEI, .Implied, null, &[_]u8{0x78});
    try checkCodeGen(.TAX, .Implied, null, &[_]u8{0xAA});
    try checkCodeGen(.TAY, .Implied, null, &[_]u8{0xA8});
    try checkCodeGen(.TSX, .Implied, null, &[_]u8{0xBA});
    try checkCodeGen(.TXA, .Implied, null, &[_]u8{0x8A});
    try checkCodeGen(.TXS, .Implied, null, &[_]u8{0x9A});
    try checkCodeGen(.TYA, .Implied, null, &[_]u8{0x98});
}

pub fn genAccumulatorInstructions() !void {
    try checkCodeGen(.ASL, .Accumulator, null, &[_]u8{0x0A});
    try checkCodeGen(.LSR, .Accumulator, null, &[_]u8{0x4A});
    try checkCodeGen(.ROL, .Accumulator, null, &[_]u8{0x2A});
    try checkCodeGen(.ROR, .Accumulator, null, &[_]u8{0x6A});
}

pub fn genImmediateInstructions() !void {
    try checkCodeGen(.ADC, .Immediate, .{ .byte = 0x10 }, &[_]u8{ 0x69, 0x10 });
    try checkCodeGen(.AND, .Immediate, .{ .byte = 0x20 }, &[_]u8{ 0x29, 0x20 });
    try checkCodeGen(.CMP, .Immediate, .{ .byte = 0x30 }, &[_]u8{ 0xC9, 0x30 });
    try checkCodeGen(.CPX, .Immediate, .{ .byte = 0x40 }, &[_]u8{ 0xE0, 0x40 });
    try checkCodeGen(.CPY, .Immediate, .{ .byte = 0x50 }, &[_]u8{ 0xC0, 0x50 });
    try checkCodeGen(.EOR, .Immediate, .{ .byte = 0x60 }, &[_]u8{ 0x49, 0x60 });
    try checkCodeGen(.LDA, .Immediate, .{ .byte = 0x70 }, &[_]u8{ 0xA9, 0x70 });
    try checkCodeGen(.LDX, .Immediate, .{ .byte = 0x88 }, &[_]u8{ 0xA2, 0x88 });
    try checkCodeGen(.LDY, .Immediate, .{ .byte = 0x99 }, &[_]u8{ 0xA0, 0x99 });
    try checkCodeGen(.ORA, .Immediate, .{ .byte = 0xAA }, &[_]u8{ 0x09, 0xAA });
    try checkCodeGen(.SBC, .Immediate, .{ .byte = 0xBB }, &[_]u8{ 0xE9, 0xBB });
}

pub fn genZeroPageInstructions() !void {
    try checkCodeGen(.ADC, .ZeroPage, .{ .byte = 0x10 }, &[_]u8{ 0x65, 0x10 });
    try checkCodeGen(.AND, .ZeroPage, .{ .byte = 0x20 }, &[_]u8{ 0x25, 0x20 });
    try checkCodeGen(.ASL, .ZeroPage, .{ .byte = 0x25 }, &[_]u8{ 0x06, 0x25 });
    try checkCodeGen(.BIT, .ZeroPage, .{ .byte = 0x2a }, &[_]u8{ 0x24, 0x2A });
    try checkCodeGen(.CMP, .ZeroPage, .{ .byte = 0x30 }, &[_]u8{ 0xC5, 0x30 });
    try checkCodeGen(.CPX, .ZeroPage, .{ .byte = 0x40 }, &[_]u8{ 0xE4, 0x40 });
    try checkCodeGen(.CPY, .ZeroPage, .{ .byte = 0x50 }, &[_]u8{ 0xC4, 0x50 });
    try checkCodeGen(.DEC, .ZeroPage, .{ .byte = 0x55 }, &[_]u8{ 0xC6, 0x55 });
    try checkCodeGen(.EOR, .ZeroPage, .{ .byte = 0x60 }, &[_]u8{ 0x45, 0x60 });
    try checkCodeGen(.INC, .ZeroPage, .{ .byte = 0x65 }, &[_]u8{ 0xE6, 0x65 });
    try checkCodeGen(.LDA, .ZeroPage, .{ .byte = 0x70 }, &[_]u8{ 0xA5, 0x70 });
    try checkCodeGen(.LDX, .ZeroPage, .{ .byte = 0x88 }, &[_]u8{ 0xA6, 0x88 });
    try checkCodeGen(.LDY, .ZeroPage, .{ .byte = 0x99 }, &[_]u8{ 0xA4, 0x99 });
    try checkCodeGen(.LSR, .ZeroPage, .{ .byte = 0x9D }, &[_]u8{ 0x46, 0x9D });
    try checkCodeGen(.ORA, .ZeroPage, .{ .byte = 0xAA }, &[_]u8{ 0x05, 0xAA });
    try checkCodeGen(.ROL, .ZeroPage, .{ .byte = 0xAB }, &[_]u8{ 0x26, 0xAB });
    try checkCodeGen(.ROR, .ZeroPage, .{ .byte = 0xAC }, &[_]u8{ 0x66, 0xAC });
    try checkCodeGen(.SBC, .ZeroPage, .{ .byte = 0xBB }, &[_]u8{ 0xE5, 0xBB });
    try checkCodeGen(.STA, .ZeroPage, .{ .byte = 0xCC }, &[_]u8{ 0x85, 0xCC });
    try checkCodeGen(.STX, .ZeroPage, .{ .byte = 0xDD }, &[_]u8{ 0x86, 0xDD });
    try checkCodeGen(.STY, .ZeroPage, .{ .byte = 0xEE }, &[_]u8{ 0x84, 0xEE });
}
