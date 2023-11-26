// zig fmt: off
const std = @import("std");
const fix = @import("./fixtures.zig");
const tr = @import("./test_runner.zig");

const Tests = tr.discoverTests(.{ 
    @import("./adc_inst.zig"), 
    @import("./and_inst.zig"), 
    @import("./asl_inst.zig"), 
    @import("./incdec_inst.zig") ,
    @import("./lsr_inst.zig"),
    @import("./ora_inst.zig")
});

pub fn main() !void {
    // for (std.os.argv) |arg| {
    //     const firstArg = std.mem.span(arg);
    //     std.debug.print("arg: {s}\n", .{firstArg});
    // }
    const verbose = if(std.os.argv.len > 1 and std.mem.eql(u8, "verbose", std.mem.span(std.os.argv[1]))) true else false;
    
    tr.runTests(Tests, verbose);
}
