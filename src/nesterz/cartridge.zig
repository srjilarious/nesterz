// iNes 1.0 cartridge structs and loading.
const std = @import("std");

pub const ScreenMirroring = enum {
    Horizontal,
    Vertical,
    FourScreen,
};

// Magic bytes at start of cartridge file. 'NES^Z'
// Stored as a u32 in LSB order.
pub const NES_MAGIC: u32 = 0x1A_53_45_4E;

const PRG_ROM_SIZE: u32 = 16 * 1024; // 16 KB
const CHR_ROM_SIZE: u32 = 8 * 1024; // 8 KB

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

    pub fn init(bytes: *std.Io.Reader, alloc: std.mem.Allocator) !Rom {
        const header = try bytes.takeStruct(INesHeader, .little);
        if (header.magic != NES_MAGIC) {
            return error.InvalidCartridge;
        }

        const mapper = (@as(u8, header.mapperUpper) << 4) | @as(u8, header.mapperLower);
        if (header.iNesFormat != 0) {
            return error.UnsupportedINesFormat;
        }

        const mirror: ScreenMirroring = blk: {
            if (header.hasFourScreenVrams) {
                break :blk ScreenMirroring.FourScreen;
            } else if (header.verticalMirroring) {
                break :blk ScreenMirroring.Vertical;
            } else {
                break :blk ScreenMirroring.Horizontal;
            }
        };

        const prgRomeSize = @as(usize, header.numPrgRomBanks) * PRG_ROM_SIZE;
        const chrRomeSize = @as(usize, header.numChrRomBanks) * CHR_ROM_SIZE;

        if (header.hasTrainer) {
            // Skip trainer if present
            _ = try bytes.discardShort(512);
        }

        const prg = try bytes.readAlloc(alloc, prgRomeSize);
        const chr = try bytes.readAlloc(alloc, chrRomeSize);

        return Rom{
            .prg = prg,
            .chr = chr,
            .mapper = mapper,
            .screenMirroring = mirror,
        };
    }
};
