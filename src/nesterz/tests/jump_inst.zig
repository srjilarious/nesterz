const std = @import("std");
const nes = @import("nesterz");
const fix = @import("fixtures.zig");
const testz = @import("testz");

const CpuFlags = nes.CpuFlags;

pub fn skip_jmpAbsoluteTest() !void {}

pub fn skip_jmpIndirectTest() !void {}

pub fn skip_jsrAbsoluteTest() !void {}

pub fn skip_rtiImpliedTest() !void {}
