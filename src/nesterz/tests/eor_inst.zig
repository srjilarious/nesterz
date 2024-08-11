const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

pub fn skip_eorImmediateTest() !void {}

pub fn skip_eorZeroPageTest() !void {}

pub fn skip_eorZeroPageXTest() !void {}

pub fn skip_eorZeroPageYTest() !void {}

pub fn skip_eorAbsoluteTest() !void {}

pub fn skip_eorAbsoluteXTest() !void {}

pub fn skip_eorIndirectXTest() !void {}

pub fn skip_eorIndirectYTest() !void {}
