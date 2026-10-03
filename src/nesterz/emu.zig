const std = @import("std");

pub const AddressMode = enum {
    Implied,
    Accumulator,
    Immediate,
    ZeroPage,
    ZeroPageX,
    ZeroPageY,
    Relative,
    Absolute,
    AbsoluteX,
    AbsoluteY,
    Indirect,
    IndirectX,
    IndirectY,
};

pub const CpuFlags = enum(u8) {
    Empty = 0,
    Carry = 0x1,
    Zero = 0x2,
    InterruptsDisabled = 0x4,
    DecimalMode = 0x8,
    Break = 0x10,
    Overflow = 0x40,
    Negative = 0x80,
    All = 0xff,
};

pub const Cpu6502State = enum {
    Startup,
    Normal,
    Halted,
};

pub const CpuOp = enum {
    UNKNOWN,
    ADC,
    AND,
    ASL,
    BCC,
    BCS,
    BEQ,
    BIT,
    BMI,
    BNE,
    BPL,
    BRK,
    BVC,
    BVS,
    CLC,
    CLD,
    CLI,
    CLV,
    CMP,
    CPX,
    CPY,
    DEC,
    DEX,
    DEY,
    EOR,
    INC,
    INX,
    INY,
    JMP,
    JSR,
    LDA,
    LDX,
    LDY,
    LSR,
    NOP,
    ORA,
    PHA,
    PHP,
    PLA,
    PLP,
    ROL,
    ROR,
    RTI,
    RTS,
    SBC,
    SEC,
    SED,
    SEI,
    STA,
    STX,
    STY,
    TAX,
    TAY,
    TSX,
    TXA,
    TXS,
    TYA,

    // Undocumented Operations
    // See docs/undocumented_opcodes.txt
    AAC,
    AAX,
    ARR,
    ASR,
    ATX,
    AXA,
    AXS,
    DCP,
    DOP,
    ISC,
    KIL,
    LAR,
    LAX,
    RLA,
    RRA,
    SLO,
    SRE,
    SXA,
    SYA,
    TOP,
    XAA,
    XAS,
};

pub fn cpuOpFromStr(opStr: []const u8) ?CpuOp {
    inline for (@typeInfo(CpuOp).@"enum".field_names) |name| {
        if (std.ascii.eqlIgnoreCase(opStr, name)) {
            return @field(CpuOp, name);
        }
    }
    return null;
}

pub fn isStore(op: CpuOp) bool {
    return switch (op) {
        .STA => true,
        .STX => true,
        .STY => true,
        else => false,
    };
}

pub fn isRelativeBranch(op: CpuOp) bool {
    return switch (op) {
        .BCC => true,
        .BCS => true,
        .BEQ => true,
        .BMI => true,
        .BNE => true,
        .BPL => true,
        .BVC => true,
        .BVS => true,
        else => false,
    };
}

pub fn expectsParam(op: CpuOp) bool {
    return switch (op) {
        .BRK => false,
        .CLC => false,
        .CLD => false,
        .CLI => false,
        .CLV => false,
        .DEX => false,
        .DEY => false,
        .INX => false,
        .INY => false,
        .NOP => false,
        .PHA => false,
        .PHP => false,
        .PLA => false,
        .PLP => false,
        .RTI => false,
        .RTS => false,
        .SEC => false,
        .SED => false,
        .SEI => false,
        .TAX => false,
        .TAY => false,
        .TSX => false,
        .TXA => false,
        .TYA => false,
        else => true,
    };
}

pub fn isStack(op: CpuOp) bool {
    return switch (op) {
        .PHA => true,
        .PLA => true,
        .PHP => true,
        .PLP => true,
        else => false,
    };
}

pub fn storesBackValue(op: CpuOp) bool {
    return switch (op) {
        .ASL => true,
        .DEC => true,
        .DEX => true,
        .DEY => true,
        .INC => true,
        .INX => true,
        .INY => true,
        .LSR => true,
        .ROL => true,
        .ROR => true,
        else => false,
    };
}

pub const ReadWriteState = enum { HighImpedance, Write, Read };

pub const EmuError = error{UnknownOp};

pub const Instruction6502 = struct {
    opCode: u8,
    op: CpuOp,
    mode: AddressMode,
    numBytes: u8,
    numCycles: u8,

    pub fn init(opCode: u8, op: CpuOp, mode: AddressMode, nb: u8, nc: u8) Instruction6502 {
        return .{ .opCode = opCode, .op = op, .mode = mode, .numBytes = nb, .numCycles = nc };
    }

    pub fn fromOpCode(opCode: u8) EmuError!Instruction6502 {
        return switch (opCode) {
            // ADC - Add with Carry
            0x69 => Instruction6502.init(opCode, .ADC, .Immediate, 2, 2),
            0x65 => Instruction6502.init(opCode, .ADC, .ZeroPage, 2, 3),
            0x75 => Instruction6502.init(opCode, .ADC, .ZeroPageX, 2, 4),
            0x6D => Instruction6502.init(opCode, .ADC, .Absolute, 3, 4),
            0x7D => Instruction6502.init(opCode, .ADC, .AbsoluteX, 3, 4),
            0x79 => Instruction6502.init(opCode, .ADC, .AbsoluteY, 3, 4),
            0x61 => Instruction6502.init(opCode, .ADC, .IndirectX, 2, 6),
            0x71 => Instruction6502.init(opCode, .ADC, .IndirectY, 2, 5),

            // AND - Logical AND
            0x29 => Instruction6502.init(opCode, .AND, .Immediate, 2, 2),
            0x25 => Instruction6502.init(opCode, .AND, .ZeroPage, 2, 3),
            0x35 => Instruction6502.init(opCode, .AND, .ZeroPageX, 2, 4),
            0x2D => Instruction6502.init(opCode, .AND, .Absolute, 3, 4),
            0x3D => Instruction6502.init(opCode, .AND, .AbsoluteX, 3, 4),
            0x39 => Instruction6502.init(opCode, .AND, .AbsoluteY, 3, 4),
            0x21 => Instruction6502.init(opCode, .AND, .IndirectX, 2, 6),
            0x31 => Instruction6502.init(opCode, .AND, .IndirectY, 2, 5),

            // ASL - Arithemtic Shift Left
            0x0A => Instruction6502.init(opCode, .ASL, .Accumulator, 1, 2),
            0x06 => Instruction6502.init(opCode, .ASL, .ZeroPage, 2, 5),
            0x16 => Instruction6502.init(opCode, .ASL, .ZeroPageX, 2, 6),
            0x0E => Instruction6502.init(opCode, .ASL, .Absolute, 3, 6),
            0x1E => Instruction6502.init(opCode, .ASL, .AbsoluteX, 3, 7),

            // BCC - Branch if Carry Clear
            0x90 => Instruction6502.init(opCode, .BCC, .Relative, 2, 2),

            // BCS - Branch if Carry Set
            0xB0 => Instruction6502.init(opCode, .BCS, .Relative, 2, 2),

            // BEQ - Branch if Equal
            0xF0 => Instruction6502.init(opCode, .BEQ, .Relative, 2, 2),

            // BIT - Bit Test
            0x24 => Instruction6502.init(opCode, .BIT, .ZeroPage, 2, 3),
            0x2C => Instruction6502.init(opCode, .BIT, .Absolute, 3, 4),

            // BMI - Branch if Minus
            0x30 => Instruction6502.init(opCode, .BMI, .Relative, 2, 2),

            // BNE - Branch if Not Equal
            0xD0 => Instruction6502.init(opCode, .BNE, .Relative, 2, 2),

            // BPL - Branch if Positive
            0x10 => Instruction6502.init(opCode, .BPL, .Relative, 2, 2),

            // BRK - Force Interrupt
            0x00 => Instruction6502.init(opCode, .BRK, .Implied, 1, 7),

            // BVC - Branch if Overflow Clear
            0x50 => Instruction6502.init(opCode, .BVC, .Relative, 2, 2),

            // BVS - Branch if Overflow Set
            0x70 => Instruction6502.init(opCode, .BVS, .Relative, 2, 2),

            // CLC - Clear Carry Flag
            0x18 => Instruction6502.init(opCode, .CLC, .Implied, 1, 2),

            // CLD - Clear Decimal Flag
            //0xD8 => Instruction6502.init(opCode, .CLD, .Implied, 1, 2),

            // CLI - Clear Carry Flag
            0x58 => Instruction6502.init(opCode, .CLI, .Implied, 1, 2),

            // CLV - Clear Overflor Flag
            0xB8 => Instruction6502.init(opCode, .CLV, .Implied, 1, 2),

            // CMP - Compare
            0xC9 => Instruction6502.init(opCode, .CMP, .Immediate, 2, 2),
            0xC5 => Instruction6502.init(opCode, .CMP, .ZeroPage, 2, 3),
            0xD5 => Instruction6502.init(opCode, .CMP, .ZeroPageX, 2, 4),
            0xCD => Instruction6502.init(opCode, .CMP, .Absolute, 3, 4),
            0xDD => Instruction6502.init(opCode, .CMP, .AbsoluteX, 3, 4),
            0xD9 => Instruction6502.init(opCode, .CMP, .AbsoluteY, 3, 4),
            0xC1 => Instruction6502.init(opCode, .CMP, .IndirectX, 2, 6),
            0xD1 => Instruction6502.init(opCode, .CMP, .IndirectY, 2, 5),

            // CPX - Compare X
            0xE0 => Instruction6502.init(opCode, .CPX, .Immediate, 2, 2),
            0xE4 => Instruction6502.init(opCode, .CPX, .ZeroPage, 2, 3),
            0xEC => Instruction6502.init(opCode, .CPX, .Absolute, 3, 4),

            // CPY - Compare Y
            0xC0 => Instruction6502.init(opCode, .CPY, .Immediate, 2, 2),
            0xC4 => Instruction6502.init(opCode, .CPY, .ZeroPage, 2, 3),
            0xCC => Instruction6502.init(opCode, .CPY, .Absolute, 3, 4),

            // DEC - Decrement
            0xC6 => Instruction6502.init(opCode, .DEC, .ZeroPage, 2, 5),
            0xD6 => Instruction6502.init(opCode, .DEC, .ZeroPageX, 2, 6),
            0xCE => Instruction6502.init(opCode, .DEC, .Absolute, 3, 6),
            0xDE => Instruction6502.init(opCode, .DEC, .AbsoluteX, 3, 7),

            // DEX - Decrement X
            0xCA => Instruction6502.init(opCode, .DEX, .Implied, 1, 2),

            // DEY - Decrement Y
            0x88 => Instruction6502.init(opCode, .DEY, .Implied, 1, 2),

            // EOR - Logical Exclusive OR
            0x49 => Instruction6502.init(opCode, .EOR, .Immediate, 2, 2),
            0x45 => Instruction6502.init(opCode, .EOR, .ZeroPage, 2, 3),
            0x55 => Instruction6502.init(opCode, .EOR, .ZeroPageX, 2, 4),
            0x4D => Instruction6502.init(opCode, .EOR, .Absolute, 3, 4),
            0x5D => Instruction6502.init(opCode, .EOR, .AbsoluteX, 3, 4),
            0x59 => Instruction6502.init(opCode, .EOR, .AbsoluteY, 3, 4),
            0x41 => Instruction6502.init(opCode, .EOR, .IndirectX, 2, 6),
            0x51 => Instruction6502.init(opCode, .EOR, .IndirectY, 2, 5),

            // INC - Increment
            0xE6 => Instruction6502.init(opCode, .INC, .ZeroPage, 2, 5),
            0xF6 => Instruction6502.init(opCode, .INC, .ZeroPageX, 2, 6),
            0xEE => Instruction6502.init(opCode, .INC, .Absolute, 3, 6),
            0xFE => Instruction6502.init(opCode, .INC, .AbsoluteX, 3, 7),

            // INX - Increment X
            0xE8 => Instruction6502.init(opCode, .INX, .Implied, 1, 2),

            // INY - Increment Y
            0xC8 => Instruction6502.init(opCode, .INY, .Implied, 1, 2),

            // JMP - Jump to address
            0x4C => Instruction6502.init(opCode, .JMP, .Absolute, 3, 3),
            0x6C => Instruction6502.init(opCode, .JMP, .Indirect, 3, 5),

            // JSR - Jump to sub-routine
            0x20 => Instruction6502.init(opCode, .JSR, .Absolute, 3, 6),

            // LDA - Load Accumulator
            0xA9 => Instruction6502.init(opCode, .LDA, .Immediate, 2, 2),
            0xA5 => Instruction6502.init(opCode, .LDA, .ZeroPage, 2, 3),
            0xB5 => Instruction6502.init(opCode, .LDA, .ZeroPageX, 2, 4),
            0xAD => Instruction6502.init(opCode, .LDA, .Absolute, 3, 4),
            0xBD => Instruction6502.init(opCode, .LDA, .AbsoluteX, 3, 4),
            0xB9 => Instruction6502.init(opCode, .LDA, .AbsoluteY, 3, 4),
            0xA1 => Instruction6502.init(opCode, .LDA, .IndirectX, 2, 6),
            0xB1 => Instruction6502.init(opCode, .LDA, .IndirectY, 2, 5),

            // LDX - Load X
            0xA2 => Instruction6502.init(opCode, .LDX, .Immediate, 2, 2),
            0xA6 => Instruction6502.init(opCode, .LDX, .ZeroPage, 2, 3),
            0xB6 => Instruction6502.init(opCode, .LDX, .ZeroPageY, 2, 4),
            0xAE => Instruction6502.init(opCode, .LDX, .Absolute, 3, 4),
            0xBE => Instruction6502.init(opCode, .LDX, .AbsoluteY, 3, 4),

            // LDY - Load Y
            0xA0 => Instruction6502.init(opCode, .LDY, .Immediate, 2, 2),
            0xA4 => Instruction6502.init(opCode, .LDY, .ZeroPage, 2, 3),
            0xB4 => Instruction6502.init(opCode, .LDY, .ZeroPageX, 2, 4),
            0xAC => Instruction6502.init(opCode, .LDY, .Absolute, 3, 4),
            0xBC => Instruction6502.init(opCode, .LDY, .AbsoluteX, 3, 4),

            // LSR - Logical Shift Right
            0x4A => Instruction6502.init(opCode, .LSR, .Accumulator, 1, 2),
            0x46 => Instruction6502.init(opCode, .LSR, .ZeroPage, 2, 5),
            0x56 => Instruction6502.init(opCode, .LSR, .ZeroPageX, 2, 6),
            0x4E => Instruction6502.init(opCode, .LSR, .Absolute, 3, 6),
            0x5E => Instruction6502.init(opCode, .LSR, .AbsoluteX, 3, 7),

            // NOP - No Operation
            0xEA => Instruction6502.init(opCode, .NOP, .Implied, 1, 2),

            // NOP - No Operation (Undocumented version)
            0x1A => Instruction6502.init(opCode, .NOP, .Implied, 1, 2),
            0x3A => Instruction6502.init(opCode, .NOP, .Implied, 1, 2),
            0x5A => Instruction6502.init(opCode, .NOP, .Implied, 1, 2),
            0x7A => Instruction6502.init(opCode, .NOP, .Implied, 1, 2),
            0xDA => Instruction6502.init(opCode, .NOP, .Implied, 1, 2),
            0xFA => Instruction6502.init(opCode, .NOP, .Implied, 1, 2),

            // ORA - Logical Inclusive OR
            0x09 => Instruction6502.init(opCode, .ORA, .Immediate, 2, 2),
            0x05 => Instruction6502.init(opCode, .ORA, .ZeroPage, 2, 3),
            0x15 => Instruction6502.init(opCode, .ORA, .ZeroPageX, 2, 4),
            0x0D => Instruction6502.init(opCode, .ORA, .Absolute, 3, 4),
            0x1D => Instruction6502.init(opCode, .ORA, .AbsoluteX, 3, 4),
            0x19 => Instruction6502.init(opCode, .ORA, .AbsoluteY, 3, 4),
            0x01 => Instruction6502.init(opCode, .ORA, .IndirectX, 2, 6),
            0x11 => Instruction6502.init(opCode, .ORA, .IndirectY, 2, 5),

            // PHA - Push Accumulator
            0x48 => Instruction6502.init(opCode, .PHA, .Implied, 1, 3),

            // PHP - Push Processor Status
            0x08 => Instruction6502.init(opCode, .PHP, .Implied, 1, 3),

            // PLA - Pull Accumulator
            0x68 => Instruction6502.init(opCode, .PLA, .Implied, 1, 4),

            // PLP - Pull Processor Status
            0x28 => Instruction6502.init(opCode, .PLP, .Implied, 1, 4),

            // ROL - Roll left
            0x2A => Instruction6502.init(opCode, .ROL, .Accumulator, 1, 2),
            0x26 => Instruction6502.init(opCode, .ROL, .ZeroPage, 2, 5),
            0x36 => Instruction6502.init(opCode, .ROL, .ZeroPageX, 2, 6),
            0x2E => Instruction6502.init(opCode, .ROL, .Absolute, 3, 6),
            0x3E => Instruction6502.init(opCode, .ROL, .AbsoluteX, 3, 7),

            // ROR - Roll right
            0x6A => Instruction6502.init(opCode, .ROR, .Accumulator, 1, 2),
            0x66 => Instruction6502.init(opCode, .ROR, .ZeroPage, 2, 5),
            0x76 => Instruction6502.init(opCode, .ROR, .ZeroPageX, 2, 6),
            0x6E => Instruction6502.init(opCode, .ROR, .Absolute, 3, 6),
            0x7E => Instruction6502.init(opCode, .ROR, .AbsoluteX, 3, 7),

            // RTI - Return from Interrupt
            0x40 => Instruction6502.init(opCode, .RTI, .Implied, 1, 6),

            // RTS - Return from Subroutine
            0x60 => Instruction6502.init(opCode, .RTS, .Implied, 1, 6),

            // SBC - Subtract with Carry
            0xE9 => Instruction6502.init(opCode, .SBC, .Immediate, 2, 2),
            0xE5 => Instruction6502.init(opCode, .SBC, .ZeroPage, 2, 3),
            0xF5 => Instruction6502.init(opCode, .SBC, .ZeroPageX, 2, 4),
            0xED => Instruction6502.init(opCode, .SBC, .Absolute, 3, 4),
            0xFD => Instruction6502.init(opCode, .SBC, .AbsoluteX, 3, 4),
            0xF9 => Instruction6502.init(opCode, .SBC, .AbsoluteY, 3, 4),
            0xE1 => Instruction6502.init(opCode, .SBC, .IndirectX, 2, 6),
            0xF1 => Instruction6502.init(opCode, .SBC, .IndirectY, 2, 5),

            // SEC - Set Carry Flag
            0x38 => Instruction6502.init(opCode, .SEC, .Implied, 1, 2),

            // SED - Decimal Flag
            //0x18 => Instruction6502.init(opCode, .SED, .Implied, 1, 2),

            // SEI - Set Interrupt Flag
            0x78 => Instruction6502.init(opCode, .SEI, .Implied, 1, 2),

            // STA - Store Accumulator
            0x85 => Instruction6502.init(opCode, .STA, .ZeroPage, 2, 3),
            0x95 => Instruction6502.init(opCode, .STA, .ZeroPageX, 2, 4),
            0x8D => Instruction6502.init(opCode, .STA, .Absolute, 3, 4),
            0x9D => Instruction6502.init(opCode, .STA, .AbsoluteX, 3, 5),
            0x99 => Instruction6502.init(opCode, .STA, .AbsoluteY, 3, 5),
            0x81 => Instruction6502.init(opCode, .STA, .IndirectX, 2, 6),
            0x91 => Instruction6502.init(opCode, .STA, .IndirectY, 2, 6),

            // STX - Store X
            0x86 => Instruction6502.init(opCode, .STX, .ZeroPage, 2, 3),
            0x96 => Instruction6502.init(opCode, .STX, .ZeroPageY, 2, 4),
            0x8E => Instruction6502.init(opCode, .STX, .Absolute, 3, 4),

            // STY - Store Y
            0x84 => Instruction6502.init(opCode, .STY, .ZeroPage, 2, 3),
            0x94 => Instruction6502.init(opCode, .STY, .ZeroPageX, 2, 4),
            0x8C => Instruction6502.init(opCode, .STY, .Absolute, 3, 4),

            // TAX - Transfer Accumulator to X
            0xAA => Instruction6502.init(opCode, .TAX, .Implied, 1, 2),

            // TAY - Transfer Accumulator to Y
            0xA8 => Instruction6502.init(opCode, .TAY, .Implied, 1, 2),

            // TSX - Transfer Stack Pointer to X
            0xBA => Instruction6502.init(opCode, .TSX, .Implied, 1, 2),

            // TXA - Transfer X to Accumulator
            0x8A => Instruction6502.init(opCode, .TXA, .Implied, 1, 2),

            // TXS - Transfer X to Stack Pointer
            0x9A => Instruction6502.init(opCode, .TXS, .Implied, 1, 2),

            // TYA - Transfer Y to Accumulator
            0x98 => Instruction6502.init(opCode, .TYA, .Implied, 1, 2),

            // ....
            else => EmuError.UnknownOp, // Err(format!("Unknown op code: {}", op_code)),
        };
    }
};
