const std = @import("std");
const testz = @import("testz");
const nes = @import("nesterz");
const nasm = @import("nesasm");

const CpuOp = nes.CpuOp;
const AddressMode = nes.AddressMode;
const Operand = nasm.Operand;

fn checkCodeGen(op: CpuOp, addr: AddressMode, operand: ?Operand, expected: []const u8) !void {
    // Buffer for storing generated instruction.
    var buff: [4]u8 = .{0} ** 4;
    const result = nasm.codeGen(op, .{ .addr = addr, .operand = operand }, &buff);
    try testz.expectEqualStr(result.?, expected);
}

pub fn genImpliedInstructions() !void {
    try checkCodeGen(.BRK, .Implied, null, &[_]u8{0x0});
    try checkCodeGen(.CLC, .Implied, null, &[_]u8{0x18});
    try checkCodeGen(.CLI, .Implied, null, &[_]u8{0x58});
    try checkCodeGen(.CLV, .Implied, null, &[_]u8{0xB8});
    try checkCodeGen(.DEX, .Implied, null, &[_]u8{0xCA});
    try checkCodeGen(.DEY, .Implied, null, &[_]u8{0x88});
    try checkCodeGen(.INX, .Implied, null, &[_]u8{0xE8});
    try checkCodeGen(.INY, .Implied, null, &[_]u8{0xC8});
    // try checkCodeGen(.NOP, .Implied, null, &[_]u8{0xEA});
    try checkCodeGen(.PHA, .Implied, null, &[_]u8{0x48});
    try checkCodeGen(.PHP, .Implied, null, &[_]u8{0x08});
    try checkCodeGen(.PLA, .Implied, null, &[_]u8{0x68});
    try checkCodeGen(.PLP, .Implied, null, &[_]u8{0x28});
    try checkCodeGen(.SEC, .Implied, null, &[_]u8{0x38});
    try checkCodeGen(.SEI, .Implied, null, &[_]u8{0x78});
    try checkCodeGen(.TAX, .Implied, null, &[_]u8{0xAA});
    try checkCodeGen(.TAY, .Implied, null, &[_]u8{0xA8});
    try checkCodeGen(.TSX, .Implied, null, &[_]u8{0xBA});
    try checkCodeGen(.TXA, .Implied, null, &[_]u8{0x8A});
    try checkCodeGen(.TXS, .Implied, null, &[_]u8{0x9A});
    try checkCodeGen(.TYA, .Implied, null, &[_]u8{0x98});
}
