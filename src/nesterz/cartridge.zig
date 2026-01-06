// iNes 1.0 cartridge structs and loading.
const std = @import("std");

pub const ScreenMirroring = enum {
    Horizontal,
    Vertical,
    FourScreen,
};

// Magic bytes at start of cartridge file. 'NES^Z'
pub const NES_MAGIC: u32 = 0x1A_53_45_4E;

// iNES 1.0 Header
pub const INesHeader = packed struct {
    magic: u32,
    numPrgRomBanks: u8,
    numChrRomBanks: u8,
    verticalMirroring: bool,
    hasBatteryBackedRam: bool,
    hasTrainer: bool,
    hasFourScreenVrams: bool,
    mapperLower: u4,
    reserved1: u2,
    iNesFormat: u2,
    mapperUpper: u4,
    prgRamSize: u8,
    unused: u56,
};

pub const Rom = struct {
    prg: []const u8,
    chr: []const u8,
    mapper: u8,
    screenMirroring: ScreenMirroring,

    pub fn init(bytes: std.io.Reader) !Rom {
        const header = try bytes.takeStruct(INesHeader);
        _ = header;
    }
};
