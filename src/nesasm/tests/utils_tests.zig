const std = @import("std");
const testz = @import("testz");
const nes = @import("nesterz");
const nasm = @import("nesasm");

const CpuOp = nes.CpuOp;
const AddressMode = nes.AddressMode;

pub fn checkOpStringParsing() !void {
    // Check a random assortment of instruction names are parsed properly.
    // Also make sure the parsing is case insensitive.
    try testz.expectEqual(nes.emu.cpuOpFromStr("ADC"), nes.CpuOp.ADC);
    try testz.expectEqual(nes.emu.cpuOpFromStr("AND"), nes.CpuOp.AND);
    try testz.expectEqual(nes.emu.cpuOpFromStr("BMI"), nes.CpuOp.BMI);
    try testz.expectEqual(nes.emu.cpuOpFromStr("CPX"), nes.CpuOp.CPX);
    try testz.expectEqual(nes.emu.cpuOpFromStr("lSR"), nes.CpuOp.LSR);
    try testz.expectEqual(nes.emu.cpuOpFromStr("Rts"), nes.CpuOp.RTS);
    try testz.expectEqual(nes.emu.cpuOpFromStr("tsx"), nes.CpuOp.TSX);

    // Make sure unknown instructions return null.
    try testz.expectEqual(nes.emu.cpuOpFromStr("boo"), null);
    try testz.expectEqual(nes.emu.cpuOpFromStr("FOO"), null);
    try testz.expectEqual(nes.emu.cpuOpFromStr("BLAH"), null);
}

pub fn checkOpCodeLookup() !void {
    // This line breaks currently because of including undocumented versions of NOP.
    // try testz.expectEqual(nasm.getOpCode(.NOP, .Implied), 0xEA);
    try testz.expectEqual(nasm.getInstFromOp(.INY, .Implied).?.opCode, 0xC8);
    try testz.expectEqual(nasm.getInstFromOp(.ADC, .Immediate).?.opCode, 0x69);
    try testz.expectEqual(nasm.getInstFromOp(.ADC, .ZeroPage).?.opCode, 0x65);
    try testz.expectEqual(nasm.getInstFromOp(.AND, .ZeroPageX).?.opCode, 0x35);
    try testz.expectEqual(nasm.getInstFromOp(.LDX, .ZeroPageY).?.opCode, 0xB6);
    try testz.expectEqual(nasm.getInstFromOp(.BEQ, .Relative).?.opCode, 0xF0);
    try testz.expectEqual(nasm.getInstFromOp(.ORA, .Absolute).?.opCode, 0x0D);
    try testz.expectEqual(nasm.getInstFromOp(.ROR, .AbsoluteX).?.opCode, 0x7E);
    try testz.expectEqual(nasm.getInstFromOp(.LDA, .AbsoluteY).?.opCode, 0xB9);
    try testz.expectEqual(nasm.getInstFromOp(.ROL, .Accumulator).?.opCode, 0x2A);
    try testz.expectEqual(nasm.getInstFromOp(.JMP, .Indirect).?.opCode, 0x6C);
    try testz.expectEqual(nasm.getInstFromOp(.SBC, .IndirectX).?.opCode, 0xE1);
    try testz.expectEqual(nasm.getInstFromOp(.SBC, .IndirectY).?.opCode, 0xF1);
}
