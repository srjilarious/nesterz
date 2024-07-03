// zig fmt: off
const std = @import("std");
const fix = @import("nesterz/tests/fixtures.zig");
const testz = @import("testz");

const Tests = testz.discoverTests(.{
    @import("nesterz/tests/adc_inst.zig"),
    @import("nesterz/tests/and_inst.zig"),
    @import("nesterz/tests/asl_inst.zig"),
    @import("nesterz/tests/branch_tests.zig"),
    @import("nesterz/tests/cmp_inst.zig"),
    @import("nesterz/tests/cpx_inst.zig"),
    @import("nesterz/tests/cpy_inst.zig"),
    @import("nesterz/tests/flag_inst.zig"),
    @import("nesterz/tests/incdec_inst.zig"),
    @import("nesterz/tests/load_inst.zig"),
    @import("nesterz/tests/lsr_inst.zig"),
    @import("nesterz/tests/ora_inst.zig"),
    @import("nesterz/tests/sbc_inst.zig"),
    @import("nesterz/tests/store_inst.zig"),
    @import("nesasm/tests/parse_tests.zig"),
    // testz.Group{ .name = "Utility tests", .tag = "utils", .mod = @import("./utils_tests.zig") },
    }, .{});

pub fn main() !void {
    try testz.testzRunner(Tests);
}
