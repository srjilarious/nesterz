const std = @import("std");
const testz = @import("testz");
const nes = @import("nesterz");

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
