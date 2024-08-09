// zig fmt: off
const std = @import("std");
const fix = @import("nesterz/tests/fixtures.zig");
const testz = @import("testz");

const Tests = testz.discoverTests(.{
    testz.Group{ .name = "ADC instruction", .tag = "adc", .mod = @import("nesterz/tests/adc_inst.zig")},
    testz.Group{ .name = "AND instruction", .tag = "and", .mod = @import("nesterz/tests/and_inst.zig")},
    testz.Group{ .name = "ASL instruction", .tag = "asl", .mod = @import("nesterz/tests/asl_inst.zig")},
    testz.Group{ .name = "Branch instructions", .tag = "branch", .mod = @import("nesterz/tests/branch_tests.zig")},
    testz.Group{ .name = "CMP instruction", .tag = "cmp", .mod = @import("nesterz/tests/cmp_inst.zig")},
    testz.Group{ .name = "CPX instruction", .tag = "cpx", .mod = @import("nesterz/tests/cpx_inst.zig")},
    testz.Group{ .name = "CPY instruction", .tag = "cpy", .mod = @import("nesterz/tests/cpy_inst.zig")},
    testz.Group{ .name = "Flag instructions", .tag = "flag", .mod = @import("nesterz/tests/flag_inst.zig")},
    testz.Group{ .name = "INC/DEC instructions", .tag = "incdec", .mod = @import("nesterz/tests/incdec_inst.zig")},
    testz.Group{ .name = "LOAD instructions", .tag = "load", .mod = @import("nesterz/tests/load_inst.zig")},
    testz.Group{ .name = "LSR instruction", .tag = "lsr", .mod = @import("nesterz/tests/lsr_inst.zig")},
    testz.Group{ .name = "ORA instruction", .tag = "ora", .mod = @import("nesterz/tests/ora_inst.zig")},
    testz.Group{ .name = "SBC instruction", .tag = "sbc", .mod = @import("nesterz/tests/sbc_inst.zig")},
    testz.Group{ .name = "Store Instructions", .tag = "store", .mod = @import("nesterz/tests/store_inst.zig")},
    testz.Group{ .name = "Assembler Utils", .tag = "asm_utils", .mod = @import("nesasm/tests/utils_tests.zig") },
    testz.Group{ .name = "Assembler Parser", .tag = "asm_parse", .mod = @import("nesasm/tests/parse_tests.zig") },
    }, .{});

pub fn main() !void {
    try testz.testzRunner(Tests);
}
