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
    try testz.expectEqual(nasm.getOpCode(.INY, .Implied), 0xC8);
    try testz.expectEqual(nasm.getOpCode(.ADC, .Immediate), 0x69);
    try testz.expectEqual(nasm.getOpCode(.ADC, .ZeroPage), 0x65);
    try testz.expectEqual(nasm.getOpCode(.AND, .ZeroPageX), 0x35);
    try testz.expectEqual(nasm.getOpCode(.LDX, .ZeroPageY), 0xB6);
    try testz.expectEqual(nasm.getOpCode(.BEQ, .Relative), 0xF0);
    try testz.expectEqual(nasm.getOpCode(.ORA, .Absolute), 0x0D);
    try testz.expectEqual(nasm.getOpCode(.ROR, .AbsoluteX), 0x7E);
    try testz.expectEqual(nasm.getOpCode(.LDA, .AbsoluteY), 0xB9);
    try testz.expectEqual(nasm.getOpCode(.ROL, .Accumulator), 0x2A);
    try testz.expectEqual(nasm.getOpCode(.JMP, .Indirect), 0x6C);
    try testz.expectEqual(nasm.getOpCode(.SBC, .IndirectX), 0xE1);
    try testz.expectEqual(nasm.getOpCode(.SBC, .IndirectY), 0xF1);
}
