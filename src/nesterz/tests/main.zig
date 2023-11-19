const std = @import("std");
const fix = @import("./fixtures.zig");
const tr = @import("./test_runner.zig");

const adcTests = @import("./adc_inst.zig");
const andTests = @import("./and_inst.zig");
const aslTests = @import("./asl_inst.zig");
const lsrTests = @import("./lsr_inst.zig");
const oraTests = @import("./ora_inst.zig");
const incdecTests = @import("./incdec_inst.zig");

const Tests = tr.discoverTests(.{ adcTests, andTests, aslTests, incdecTests });

pub fn main() !void {
    tr.runTests(Tests, true);
}
