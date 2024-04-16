// zig fmt: off
const std = @import("std");
const nes = @import("nesterz");
const structs = @import("./structs.zig");

const CpuOp = nes.CpuOp;
const AddressMode = nes.AddressMode;

const Operand = structs.Operand;
const Instruction = structs.Instruction;
const InstructionBytes = structs.InstructionBytes;
const Label = structs.Label;
const AssemblyLine = structs.AssemblyLine;
const AssemblyError = structs.AssemblyError;
const AssemblyParseError = structs.AssemblyParseError;

pub const Assembler6502 = struct {
    alloc: std.mem.Allocator,
    labels: std.ArrayList(Label),
    symbols: std.StringHashMap(Operand),
    lines: std.ArrayList(AssemblyLine),
    currLineNo: usize,
    currByteOffset: usize,
    // instMap: InstructionMap,
    
    pub fn init(alloc: std.mem.Allocator) !Assembler6502 {
        return .{
            .alloc = alloc,
            .labels = std.ArrayList(Label).init(alloc),
            .symbols = std.StringHashMap(Operand).init(alloc),
            .lines = std.ArrayList(AssemblyLine).init(alloc),
            .currLineNo = 0,
            .currByteOffset = 0
        };
    }

    pub fn deinit(self: *Assembler6502) void {
        // TODO: implement
        self.labels.deinit();
        self.symbols.deinit();
        self.lines.deinit();
    }
};
