const std = @import("std");

pub const emu = @import("./emu.zig");
pub const cpu = @import("./cpu.zig");

pub const CpuState = emu.Cpu6502State;
pub const Instruction = emu.Instruction6502;
pub const ReadWriteState = emu.ReadWriteState;
pub const CpuOp = emu.CpuOp;
pub const AddressMode = emu.AddressMode;
pub const CpuFlags = emu.CpuFlags;
pub const Cpu6502 = cpu.Cpu6502;

test "Top level test" {
    std.debug.print("Yay!\n", .{});
}

pub const math_test = @import("tests/math_tests.zig");
