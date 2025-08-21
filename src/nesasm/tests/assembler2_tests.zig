const std = @import("std");
const testz = @import("testz");
const nes = @import("nesterz");
const nasm = @import("nesasm");
const Assembler6502 = nasm.assembler2.Assembler6502;
const AssemblyLine = nasm.AssemblyLine;
const CpuOp = nasm.CpuOp;

pub fn testSingleInstAssembly() !void {
    const alloc = std.heap.page_allocator;
    var assembler = try Assembler6502.init(alloc, "BRK");
    defer assembler.deinit();

    const line = try assembler.parseNextLine();
    try testz.expectNotEqual(line, null);
    try testz.expectNotEqual(line.?.instr, null);
    try testz.expectEqual(line.?.instr.?.op, .BRK);
    try testz.expectTrue(assembler.isEof());
}
