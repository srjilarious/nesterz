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

pub fn testInstWithImmediateAssembly() !void {
    const alloc = std.heap.page_allocator;
    var assembler = try Assembler6502.init(alloc, "ADC #$10");
    defer assembler.deinit();

    const line = try assembler.parseNextLine();
    try testz.expectNotEqual(line, null);
    try testz.expectNotEqual(line.?.instr, null);
    try testz.expectEqual(line.?.instr.?.op, .ADC);
    try testz.expectEqual(line.?.instr.?.addrMode, .Immediate);
    try testz.expectEqual(line.?.instr.?.operand.?.byte, 16);
    try testz.expectTrue(assembler.isEof());
}

pub fn testInstWithZeroPageAssembly() !void {
    const alloc = std.heap.page_allocator;
    var assembler = try Assembler6502.init(alloc, "ADC $10");
    defer assembler.deinit();

    const line = try assembler.parseNextLine();
    try testz.expectNotEqual(line, null);
    try testz.expectNotEqual(line.?.instr, null);
    try testz.expectEqual(line.?.instr.?.op, .ADC);
    try testz.expectEqual(line.?.instr.?.addrMode, .ZeroPage);
    try testz.expectEqual(line.?.instr.?.operand.?.byte, 16);
    try testz.expectTrue(assembler.isEof());
}

pub fn testInstWithAbsoluteAssembly() !void {
    const alloc = std.heap.page_allocator;
    var assembler = try Assembler6502.init(alloc, "ADC $2000");
    defer assembler.deinit();

    const line = try assembler.parseNextLine();
    try testz.expectNotEqual(line, null);
    try testz.expectNotEqual(line.?.instr, null);
    try testz.expectEqual(line.?.instr.?.op, .ADC);
    try testz.expectEqual(line.?.instr.?.addrMode, .Absolute);
    try testz.expectEqual(line.?.instr.?.operand.?.word, 8192);
    try testz.expectTrue(assembler.isEof());
}
