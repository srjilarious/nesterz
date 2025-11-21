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

pub fn genZeroPageXInstructions() !void {
    try checkCodeGen(.ADC, .ZeroPageX, .{ .byte = 0x10 }, &[_]u8{ 0x75, 0x10 });
    try checkCodeGen(.AND, .ZeroPageX, .{ .byte = 0x20 }, &[_]u8{ 0x35, 0x20 });
    try checkCodeGen(.ASL, .ZeroPageX, .{ .byte = 0x25 }, &[_]u8{ 0x16, 0x25 });
    try checkCodeGen(.CMP, .ZeroPageX, .{ .byte = 0x30 }, &[_]u8{ 0xD5, 0x30 });
    try checkCodeGen(.DEC, .ZeroPageX, .{ .byte = 0x55 }, &[_]u8{ 0xD6, 0x55 });
    try checkCodeGen(.EOR, .ZeroPageX, .{ .byte = 0x60 }, &[_]u8{ 0x55, 0x60 });
    try checkCodeGen(.INC, .ZeroPageX, .{ .byte = 0x65 }, &[_]u8{ 0xF6, 0x65 });
    try checkCodeGen(.LDA, .ZeroPageX, .{ .byte = 0x70 }, &[_]u8{ 0xB5, 0x70 });
    try checkCodeGen(.LDY, .ZeroPageX, .{ .byte = 0x99 }, &[_]u8{ 0xB4, 0x99 });
    try checkCodeGen(.LSR, .ZeroPageX, .{ .byte = 0x9D }, &[_]u8{ 0x56, 0x9D });
    try checkCodeGen(.ORA, .ZeroPageX, .{ .byte = 0xAA }, &[_]u8{ 0x15, 0xAA });
    try checkCodeGen(.ROL, .ZeroPageX, .{ .byte = 0xAB }, &[_]u8{ 0x36, 0xAB });
    try checkCodeGen(.ROR, .ZeroPageX, .{ .byte = 0xAC }, &[_]u8{ 0x76, 0xAC });
    try checkCodeGen(.SBC, .ZeroPageX, .{ .byte = 0xBB }, &[_]u8{ 0xF5, 0xBB });
    try checkCodeGen(.STA, .ZeroPageX, .{ .byte = 0xCC }, &[_]u8{ 0x95, 0xCC });
    try checkCodeGen(.STY, .ZeroPageX, .{ .byte = 0xEE }, &[_]u8{ 0x94, 0xEE });
}

pub fn genZeroPageYInstructions() !void {
    try checkCodeGen(.LDX, .ZeroPageY, .{ .byte = 0x10 }, &[_]u8{ 0xB6, 0x10 });
    try checkCodeGen(.STX, .ZeroPageY, .{ .byte = 0x20 }, &[_]u8{ 0x96, 0x20 });
}

pub fn genRelativeInstructions() !void {
    try checkCodeGen(.BCC, .Relative, .{ .byte = 0x10 }, &[_]u8{ 0x90, 0x10 });
    try checkCodeGen(.BCS, .Relative, .{ .byte = 0x20 }, &[_]u8{ 0xB0, 0x20 });
    try checkCodeGen(.BEQ, .Relative, .{ .byte = 0x30 }, &[_]u8{ 0xF0, 0x30 });
    try checkCodeGen(.BMI, .Relative, .{ .byte = 0x40 }, &[_]u8{ 0x30, 0x40 });
    try checkCodeGen(.BNE, .Relative, .{ .byte = 0x50 }, &[_]u8{ 0xD0, 0x50 });
    try checkCodeGen(.BPL, .Relative, .{ .byte = 0x60 }, &[_]u8{ 0x10, 0x60 });
    try checkCodeGen(.BVC, .Relative, .{ .byte = 0x70 }, &[_]u8{ 0x50, 0x70 });
    try checkCodeGen(.BVS, .Relative, .{ .byte = 0x80 }, &[_]u8{ 0x70, 0x80 });
}

pub fn genAbsoluteInstructions() !void {
    try checkCodeGen(.ADC, .Absolute, .{ .word = 0x3010 }, &[_]u8{ 0x6D, 0x10, 0x30 });
    try checkCodeGen(.AND, .Absolute, .{ .word = 0x3020 }, &[_]u8{ 0x2D, 0x20, 0x30 });
    try checkCodeGen(.ASL, .Absolute, .{ .word = 0x3025 }, &[_]u8{ 0x0E, 0x25, 0x30 });
    try checkCodeGen(.BIT, .Absolute, .{ .word = 0x302a }, &[_]u8{ 0x2C, 0x2A, 0x30 });
    try checkCodeGen(.CMP, .Absolute, .{ .word = 0x3030 }, &[_]u8{ 0xCD, 0x30, 0x30 });
    try checkCodeGen(.CPX, .Absolute, .{ .word = 0x3040 }, &[_]u8{ 0xEC, 0x40, 0x30 });
    try checkCodeGen(.CPY, .Absolute, .{ .word = 0x3050 }, &[_]u8{ 0xCC, 0x50, 0x30 });
    try checkCodeGen(.DEC, .Absolute, .{ .word = 0x3055 }, &[_]u8{ 0xCE, 0x55, 0x30 });
    try checkCodeGen(.EOR, .Absolute, .{ .word = 0x3060 }, &[_]u8{ 0x4D, 0x60, 0x30 });
    try checkCodeGen(.INC, .Absolute, .{ .word = 0x3065 }, &[_]u8{ 0xEE, 0x65, 0x30 });
    try checkCodeGen(.LDA, .Absolute, .{ .word = 0x3070 }, &[_]u8{ 0xAD, 0x70, 0x30 });
    try checkCodeGen(.LDX, .Absolute, .{ .word = 0x3088 }, &[_]u8{ 0xAE, 0x88, 0x30 });
    try checkCodeGen(.LDY, .Absolute, .{ .word = 0x3099 }, &[_]u8{ 0xAC, 0x99, 0x30 });
    try checkCodeGen(.LSR, .Absolute, .{ .word = 0x309D }, &[_]u8{ 0x4E, 0x9D, 0x30 });
    try checkCodeGen(.ORA, .Absolute, .{ .word = 0x30AA }, &[_]u8{ 0x0D, 0xAA, 0x30 });
    try checkCodeGen(.ROL, .Absolute, .{ .word = 0x30AB }, &[_]u8{ 0x2E, 0xAB, 0x30 });
    try checkCodeGen(.ROR, .Absolute, .{ .word = 0x30AC }, &[_]u8{ 0x6E, 0xAC, 0x30 });
    try checkCodeGen(.SBC, .Absolute, .{ .word = 0x30BB }, &[_]u8{ 0xED, 0xBB, 0x30 });
    try checkCodeGen(.STA, .Absolute, .{ .word = 0x30CC }, &[_]u8{ 0x8D, 0xCC, 0x30 });
    try checkCodeGen(.STX, .Absolute, .{ .word = 0x30DD }, &[_]u8{ 0x8E, 0xDD, 0x30 });
    try checkCodeGen(.STY, .Absolute, .{ .word = 0x30EE }, &[_]u8{ 0x8C, 0xEE, 0x30 });
}

pub fn genAbsoluteXInstructions() !void {
    try checkCodeGen(.ADC, .AbsoluteX, .{ .word = 0x3010 }, &[_]u8{ 0x7D, 0x10, 0x30 });
    try checkCodeGen(.AND, .AbsoluteX, .{ .word = 0x3020 }, &[_]u8{ 0x3D, 0x20, 0x30 });
    try checkCodeGen(.ASL, .AbsoluteX, .{ .word = 0x3025 }, &[_]u8{ 0x1E, 0x25, 0x30 });
    try checkCodeGen(.CMP, .AbsoluteX, .{ .word = 0x3030 }, &[_]u8{ 0xDD, 0x30, 0x30 });
    try checkCodeGen(.DEC, .AbsoluteX, .{ .word = 0x3055 }, &[_]u8{ 0xDE, 0x55, 0x30 });
    try checkCodeGen(.EOR, .AbsoluteX, .{ .word = 0x3060 }, &[_]u8{ 0x5D, 0x60, 0x30 });
    try checkCodeGen(.INC, .AbsoluteX, .{ .word = 0x3065 }, &[_]u8{ 0xFE, 0x65, 0x30 });
    try checkCodeGen(.LDA, .AbsoluteX, .{ .word = 0x3070 }, &[_]u8{ 0xBD, 0x70, 0x30 });
    try checkCodeGen(.LDY, .AbsoluteX, .{ .word = 0x3099 }, &[_]u8{ 0xBC, 0x99, 0x30 });
    try checkCodeGen(.LSR, .AbsoluteX, .{ .word = 0x309D }, &[_]u8{ 0x5E, 0x9D, 0x30 });
    try checkCodeGen(.ORA, .AbsoluteX, .{ .word = 0x30AA }, &[_]u8{ 0x1D, 0xAA, 0x30 });
    try checkCodeGen(.ROL, .AbsoluteX, .{ .word = 0x30AB }, &[_]u8{ 0x3E, 0xAB, 0x30 });
    try checkCodeGen(.ROR, .AbsoluteX, .{ .word = 0x30AC }, &[_]u8{ 0x7E, 0xAC, 0x30 });
    try checkCodeGen(.SBC, .AbsoluteX, .{ .word = 0x30BB }, &[_]u8{ 0xFD, 0xBB, 0x30 });
    try checkCodeGen(.STA, .AbsoluteX, .{ .word = 0x30CC }, &[_]u8{ 0x9D, 0xCC, 0x30 });
}

pub fn genAbsoluteYInstructions() !void {
    try checkCodeGen(.ADC, .AbsoluteY, .{ .word = 0x3010 }, &[_]u8{ 0x79, 0x10, 0x30 });
    try checkCodeGen(.AND, .AbsoluteY, .{ .word = 0x3020 }, &[_]u8{ 0x39, 0x20, 0x30 });
    try checkCodeGen(.CMP, .AbsoluteY, .{ .word = 0x3030 }, &[_]u8{ 0xD9, 0x30, 0x30 });
    try checkCodeGen(.EOR, .AbsoluteY, .{ .word = 0x3060 }, &[_]u8{ 0x59, 0x60, 0x30 });
    try checkCodeGen(.LDA, .AbsoluteY, .{ .word = 0x3070 }, &[_]u8{ 0xB9, 0x70, 0x30 });
    try checkCodeGen(.LDX, .AbsoluteY, .{ .word = 0x3088 }, &[_]u8{ 0xBE, 0x88, 0x30 });
    try checkCodeGen(.ORA, .AbsoluteY, .{ .word = 0x30AA }, &[_]u8{ 0x19, 0xAA, 0x30 });
    try checkCodeGen(.SBC, .AbsoluteY, .{ .word = 0x30BB }, &[_]u8{ 0xF9, 0xBB, 0x30 });
    try checkCodeGen(.STA, .AbsoluteY, .{ .word = 0x30CC }, &[_]u8{ 0x99, 0xCC, 0x30 });
}

pub fn getIndirectInstructions() !void {
    try checkCodeGen(.JMP, .Indirect, .{ .word = 0x3010 }, &[_]u8{ 0x6C, 0x10, 0x30 });
}

pub fn genIndirectXInstructions() !void {
    try checkCodeGen(.ADC, .IndirectX, .{ .byte = 0x10 }, &[_]u8{ 0x61, 0x10 });
    try checkCodeGen(.AND, .IndirectX, .{ .byte = 0x20 }, &[_]u8{ 0x21, 0x20 });
    try checkCodeGen(.CMP, .IndirectX, .{ .byte = 0x30 }, &[_]u8{ 0xC1, 0x30 });
    try checkCodeGen(.EOR, .IndirectX, .{ .byte = 0x60 }, &[_]u8{ 0x41, 0x60 });
    try checkCodeGen(.LDA, .IndirectX, .{ .byte = 0x70 }, &[_]u8{ 0xA1, 0x70 });
    try checkCodeGen(.ORA, .IndirectX, .{ .byte = 0xAA }, &[_]u8{ 0x01, 0xAA });
    try checkCodeGen(.SBC, .IndirectX, .{ .byte = 0xBB }, &[_]u8{ 0xE1, 0xBB });
    try checkCodeGen(.STA, .IndirectX, .{ .byte = 0xCC }, &[_]u8{ 0x81, 0xCC });
}
