const std = @import("std");
const nes = @import("nesterz");
const testz = @import("testz");

pub fn checkBasicCatridgeHeaderParsing() !void {
    try testz.expectEqual(@sizeOf(nes.catridge.INesHeader), 16);

    const data: [16]u8 = [_]u8{
        0x4E, 0x45, 0x53, 0x1A, // NES^Z
        0x2, // 2 PRG ROM banks
        0x3, // 1 CHR ROM bank
        0b0101_1011, // First control byte
        0b0110_0000, // Second control byte
        0x5, // 5 PRG RAM banks
        0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, // Unused
    };
    var reader = std.Io.Reader.fixed(data[0..]);
    const header = try reader.takeStruct(nes.catridge.INesHeader, .little);

    try testz.expectEqual(header.magic, nes.catridge.NES_MAGIC);
    try testz.expectEqual(header.numPrgRomBanks, 2);
    try testz.expectEqual(header.numChrRomBanks, 3);
    try testz.expectEqual(header.verticalMirroring, true);
    try testz.expectEqual(header.hasBatteryBackedRam, true);
    try testz.expectEqual(header.hasTrainer, false);
    try testz.expectEqual(header.hasFourScreenVrams, true);
    try testz.expectEqual(header.mapperLower, 0b0101);
    try testz.expectEqual(header.iNesFormat, 0);
    try testz.expectEqual(header.mapperUpper, 0b0110);
    try testz.expectEqual(header.prgRamSize, 5);
}

pub fn checkEmptyCatridgeLoad() !void {
    const data: [16]u8 = [_]u8{
        0x4E, 0x45, 0x53, 0x1A, // NES^Z
        0x0, // 0 PRG ROM banks
        0x0, // 0 CHR ROM bank
        0b0101_1011, // First control byte
        0b0110_0000, // Second control byte
        0x5, // 5 PRG RAM banks
        0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, // Unused
    };
    var reader = std.Io.Reader.fixed(data[0..]);
    const rom = try nes.catridge.Rom.init(&reader, std.heap.page_allocator);
    try testz.expectEqual(rom.prg.len, 0);
    try testz.expectEqual(rom.chr.len, 0);
    try testz.expectEqual(rom.mapper, 0b0110_0101);
    try testz.expectEqual(rom.screenMirroring, nes.catridge.ScreenMirroring.FourScreen);
}
