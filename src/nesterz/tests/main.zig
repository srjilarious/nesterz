// zig fmt: off
const std = @import("std");
const fix = @import("./fixtures.zig");
const tr = @import("./test_runner.zig");

const lsrTests = @import("./lsr_inst.zig");
const oraTests = @import("./ora_inst.zig");

const Tests = tr.discoverTests(.{ 
    @import("./adc_inst.zig"), 
    @import("./and_inst.zig"), 
    @import("./asl_inst.zig"), 
    @import("./incdec_inst.zig") 
});

pub fn main() !void {
    tr.runTests(Tests, true);
}
