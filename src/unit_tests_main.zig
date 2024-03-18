// zig fmt: off
const std = @import("std");
const fix = @import("nesterz/tests/fixtures.zig");
const testz = @import("testz");


const SystemTests = testz.discoverTests(.{ 
    @import("nesterz/tests/adc_inst.zig"),
    @import("nesterz/tests/and_inst.zig"),
    @import("nesterz/tests/asl_inst.zig"),
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
});

const AssemblerTests = testz.discoverTests(.{
    @import("nesasm/tests/parse_tests.zig"),
});

pub fn main() void {
    // for (std.os.argv) |arg| {
    //     const firstArg = std.mem.span(arg);
    //     std.debug.print("arg: {s}\n", .{firstArg});
    // }
    const verbose = if(std.os.argv.len > 1 and std.mem.eql(u8, "verbose", std.mem.span(std.os.argv[1]))) true else false;
    
    if(verbose) {
        std.debug.print("# NES System Tests:\n", .{});
    }
    _ = testz.runTests(SystemTests, verbose);

    if(verbose) {
        std.debug.print("# NES Assembler Tests:\n", .{});
    }
    _ = testz.runTests(AssemblerTests, verbose);
}
