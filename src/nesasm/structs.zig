const std = @import("std");
const nes = @import("nesterz");

const CpuOp = nes.CpuOp;
const AddressMode = nes.AddressMode;
pub const Operand = union(enum) {
    byte: u8,
    word: u16,
};

pub const Instruction = struct {
    op: CpuOp,
    addrMode: AddressMode,
    operand: ?Operand,
};

pub const InstructionBytes = struct { data: [3]u8, len: u8 };

pub const Label = struct {
    name: []const u8,
    line: usize,
    byteLoc: usize,

    pub fn init(name: []const u8, line: usize, loc: usize, alloc: std.mem.Allocator) !Label {
        return .{
            .name = alloc.dupe(name),
            .line = line,
            .byteLoc = loc,
        };
    }

    pub fn deinit(self: *Label) !void {
        self.alloc.free(self.name);
    }
};

pub const AssemblyLine = struct {
    instr: ?Instruction,
    label: ?Label,
    comment: ?[]const u8,
    lineNo: usize,
};

pub const AssemblyError = struct {
    err: AssemblyParseError,
    lineNo: usize,
    line: []const u8,
};

pub const AssemblyParseError = union(enum) {
    UnknownError,
    UnknownOp: []const u8,
    InvalidAddressMode: AddressMode,
    OperandTooBig: i32,
    MissingSymbol: []const u8,
    MissingSymbolName,
    MissingSymbolValue,
    SymbolRedefinition,
    UnknownDirective: []const u8,
    MissingDirectiveValue,
};
