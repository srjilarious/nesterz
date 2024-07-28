// zig fmt: off
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
    IndirectY 
};

pub const CpuFlags = enum(u8) {
    Empty = 0,
    Carry  = 0x1,
    Zero = 0x2,
    InterruptsDisabled = 0x4,
    DecimalMode = 0x8,
    Break = 0x10,
    Overflow = 0x20,
    Negative = 0x80,
    All = 0xff
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

pub fn isStore(op: CpuOp) bool {
    return switch (op) {
        CpuOp.STA => true,
        CpuOp.STX => true,
        CpuOp.STY => true,
        else => false,
    };
}

pub fn isRelativeBranch(op: CpuOp) bool {
    return switch (op) {
        CpuOp.BCC => true,
        CpuOp.BCS => true,
        CpuOp.BEQ => true,
        CpuOp.BMI => true,
        CpuOp.BNE => true,
        CpuOp.BPL => true,
        CpuOp.BVC => true,
        CpuOp.BVS => true,
        else => false,
    };
}

pub fn expectsParam(op: CpuOp) bool {
    return switch (op) {
        CpuOp.BRK => false,
        CpuOp.CLC => false,
        CpuOp.CLD => false,
        CpuOp.CLI => false,
        CpuOp.CLV => false,
        CpuOp.DEX => false,
        CpuOp.DEY => false,
        CpuOp.INX => false,
        CpuOp.INY => false,
        CpuOp.NOP => false,
        CpuOp.PHA => false,
        CpuOp.PHP => false,
        CpuOp.PLA => false,
        CpuOp.PLP => false,
        CpuOp.RTI => false,
        CpuOp.RTS => false,
        CpuOp.SEC => false,
        CpuOp.SED => false,
        CpuOp.SEI => false,
        CpuOp.TAX => false,
        CpuOp.TAY => false,
        CpuOp.TSX => false,
        CpuOp.TXA => false,
        CpuOp.TYA => false,
        else => true,
    };
}

pub fn isStack(op: CpuOp) bool {
    return switch (op) {
        CpuOp.PHA => true,
        CpuOp.PLA => true,
        CpuOp.PHP => true,
        CpuOp.PLP => true,
        else => false,
    };
}

pub fn storesBackValue(op: CpuOp) bool {
    return switch (op) {
        CpuOp.ASL => true,
        CpuOp.DEC => true,
        CpuOp.DEX => true,
        CpuOp.DEY => true,
        CpuOp.INC => true,
        CpuOp.INX => true,
        CpuOp.INY => true,
        CpuOp.LSR => true,
        CpuOp.ROL => true,
        CpuOp.ROR => true,
        else => false,
    };
}

pub const ReadWriteState = enum { 
    HighImpedance, 
    Write, 
    Read 
};

pub const EmuError = error {
    UnknownOp
};

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
            0x69 => Instruction6502.init(opCode, CpuOp.ADC, AddressMode.Immediate, 2, 2),
            0x65 => Instruction6502.init(opCode, CpuOp.ADC, AddressMode.ZeroPage, 2, 3),
            0x75 => Instruction6502.init(opCode, CpuOp.ADC, AddressMode.ZeroPageX, 2, 4),
            0x6D => Instruction6502.init(opCode, CpuOp.ADC, AddressMode.Absolute, 3, 4),
            0x7D => Instruction6502.init(opCode, CpuOp.ADC, AddressMode.AbsoluteX, 3, 4),
            0x79 => Instruction6502.init(opCode, CpuOp.ADC, AddressMode.AbsoluteY, 3, 4),
            0x61 => Instruction6502.init(opCode, CpuOp.ADC, AddressMode.IndirectX, 2, 6),
            0x71 => Instruction6502.init(opCode, CpuOp.ADC, AddressMode.IndirectY, 2, 5),

            // AND - Logical AND
            0x29 => Instruction6502.init(opCode, CpuOp.AND, AddressMode.Immediate, 2, 2),
            0x25 => Instruction6502.init(opCode, CpuOp.AND, AddressMode.ZeroPage, 2, 3),
            0x35 => Instruction6502.init(opCode, CpuOp.AND, AddressMode.ZeroPageX, 2, 4),
            0x2D => Instruction6502.init(opCode, CpuOp.AND, AddressMode.Absolute, 3, 4),
            0x3D => Instruction6502.init(opCode, CpuOp.AND, AddressMode.AbsoluteX, 3, 4),
            0x39 => Instruction6502.init(opCode, CpuOp.AND, AddressMode.AbsoluteY, 3, 4),
            0x21 => Instruction6502.init(opCode, CpuOp.AND, AddressMode.IndirectX, 2, 6),
            0x31 => Instruction6502.init(opCode, CpuOp.AND, AddressMode.IndirectY, 2, 5),

            // ASL - Arithemtic Shift Left
            0x0A => Instruction6502.init(opCode, CpuOp.ASL, AddressMode.Accumulator, 1, 2),
            0x06 => Instruction6502.init(opCode, CpuOp.ASL, AddressMode.ZeroPage, 2, 5),
            0x16 => Instruction6502.init(opCode, CpuOp.ASL, AddressMode.ZeroPageX, 2, 6),
            0x0E => Instruction6502.init(opCode, CpuOp.ASL, AddressMode.Absolute, 3, 6),
            0x1E => Instruction6502.init(opCode, CpuOp.ASL, AddressMode.AbsoluteX, 3, 7),

            // BCC - Branch if Carry Clear
            0x90 => Instruction6502.init(opCode, CpuOp.BCC, AddressMode.Relative, 2, 2),

            // BCS - Branch if Carry Set
            0xB0 => Instruction6502.init(opCode, CpuOp.BCS, AddressMode.Relative, 2, 2),

            // BEQ - Branch if Equal
            0xF0 => Instruction6502.init(opCode, CpuOp.BEQ, AddressMode.Relative, 2, 2),

            // BIT - Bit Test
            0x24 => Instruction6502.init(opCode, CpuOp.BIT, AddressMode.ZeroPage, 2, 3),
            0x2C => Instruction6502.init(opCode, CpuOp.BIT, AddressMode.Absolute, 3, 4),

            // BMI - Branch if Minus
            0x30 => Instruction6502.init(opCode, CpuOp.BMI, AddressMode.Relative, 2, 2),

            // BNE - Branch if Not Equal
            0xD0 => Instruction6502.init(opCode, CpuOp.BNE, AddressMode.Relative, 2, 2),

            // BPL - Branch if Positive
            0x10 => Instruction6502.init(opCode, CpuOp.BPL, AddressMode.Relative, 2, 2),

            // BRK - Force Interrupt
            0x00 => Instruction6502.init(opCode, CpuOp.BRK, AddressMode.Implied, 1, 7),

            // BVC - Branch if Overflow Clear
            0x50 => Instruction6502.init(opCode, CpuOp.BVC, AddressMode.Relative, 2, 2),

            // BVS - Branch if Overflow Set
            0x70 => Instruction6502.init(opCode, CpuOp.BVS, AddressMode.Relative, 2, 2),

            // CLC - Clear Carry Flag
            0x18 => Instruction6502.init(opCode, CpuOp.CLC, AddressMode.Implied, 1, 2),

            // CLD - Clear Decimal Flag
            //0xD8 => Instruction6502.init(opCode, CpuOp.CLD, AddressMode.Implied, 1, 2),

            // CLI - Clear Carry Flag
            0x58 => Instruction6502.init(opCode, CpuOp.CLI, AddressMode.Implied, 1, 2),

            // CLV - Clear Overflor Flag
            0xB8 => Instruction6502.init(opCode, CpuOp.CLV, AddressMode.Implied, 1, 2),

            // CMP - Compare
            0xC9 => Instruction6502.init(opCode, CpuOp.CMP, AddressMode.Immediate, 2, 2),
            0xC5 => Instruction6502.init(opCode, CpuOp.CMP, AddressMode.ZeroPage, 2, 3),
            0xD5 => Instruction6502.init(opCode, CpuOp.CMP, AddressMode.ZeroPageX, 2, 4),
            0xCD => Instruction6502.init(opCode, CpuOp.CMP, AddressMode.Absolute, 3, 4),
            0xDD => Instruction6502.init(opCode, CpuOp.CMP, AddressMode.AbsoluteX, 3, 4),
            0xD9 => Instruction6502.init(opCode, CpuOp.CMP, AddressMode.AbsoluteY, 3, 4),
            0xC1 => Instruction6502.init(opCode, CpuOp.CMP, AddressMode.IndirectX, 2, 6),
            0xD1 => Instruction6502.init(opCode, CpuOp.CMP, AddressMode.IndirectY, 2, 5),

            // CPX - Compare X
            0xE0 => Instruction6502.init(opCode, CpuOp.CPX, AddressMode.Immediate, 2, 2),
            0xE4 => Instruction6502.init(opCode, CpuOp.CPX, AddressMode.ZeroPage, 2, 3),
            0xEC => Instruction6502.init(opCode, CpuOp.CPX, AddressMode.Absolute, 3, 4),

            // CPY - Compare Y
            0xC0 => Instruction6502.init(opCode, CpuOp.CPY, AddressMode.Immediate, 2, 2),
            0xC4 => Instruction6502.init(opCode, CpuOp.CPY, AddressMode.ZeroPage, 2, 3),
            0xCC => Instruction6502.init(opCode, CpuOp.CPY, AddressMode.Absolute, 3, 4),

            // DEC - Decrement
            0xC6 => Instruction6502.init(opCode, CpuOp.DEC, AddressMode.ZeroPage, 2, 5),
            0xD6 => Instruction6502.init(opCode, CpuOp.DEC, AddressMode.ZeroPageX, 2, 6),
            0xCE => Instruction6502.init(opCode, CpuOp.DEC, AddressMode.Absolute, 3, 6),
            0xDE => Instruction6502.init(opCode, CpuOp.DEC, AddressMode.AbsoluteX, 3, 7),

            // DEX - Decrement X
            0xCA => Instruction6502.init(opCode, CpuOp.DEX, AddressMode.Implied, 1, 2),

            // DEY - Decrement Y
            0x88 => Instruction6502.init(opCode, CpuOp.DEY, AddressMode.Implied, 1, 2),

            // EOR - Logical Exclusive OR
            0x49 => Instruction6502.init(opCode, CpuOp.EOR, AddressMode.Immediate, 2, 2),
            0x45 => Instruction6502.init(opCode, CpuOp.EOR, AddressMode.ZeroPage, 2, 3),
            0x55 => Instruction6502.init(opCode, CpuOp.EOR, AddressMode.ZeroPageX, 2, 4),
            0x4D => Instruction6502.init(opCode, CpuOp.EOR, AddressMode.Absolute, 3, 4),
            0x5D => Instruction6502.init(opCode, CpuOp.EOR, AddressMode.AbsoluteX, 3, 4),
            0x59 => Instruction6502.init(opCode, CpuOp.EOR, AddressMode.AbsoluteY, 3, 4),
            0x41 => Instruction6502.init(opCode, CpuOp.EOR, AddressMode.IndirectX, 2, 6),
            0x51 => Instruction6502.init(opCode, CpuOp.EOR, AddressMode.IndirectY, 2, 5),

            // INC - Increment
            0xE6 => Instruction6502.init(opCode, CpuOp.INC, AddressMode.ZeroPage, 2, 5),
            0xF6 => Instruction6502.init(opCode, CpuOp.INC, AddressMode.ZeroPageX, 2, 6),
            0xEE => Instruction6502.init(opCode, CpuOp.INC, AddressMode.Absolute, 3, 6),
            0xFE => Instruction6502.init(opCode, CpuOp.INC, AddressMode.AbsoluteX, 3, 7),

            // INX - Increment X
            0xE8 => Instruction6502.init(opCode, CpuOp.INX, AddressMode.Implied, 1, 2),

            // INY - Increment Y
            0xC8 => Instruction6502.init(opCode, CpuOp.INY, AddressMode.Implied, 1, 2),

            // JMP - Jump to address
            0x4C => Instruction6502.init(opCode, CpuOp.JMP, AddressMode.Absolute, 3, 3),
            0x6C => Instruction6502.init(opCode, CpuOp.JMP, AddressMode.Indirect, 3, 5),

            // JSR - Jump to sub-routine
            0x20 => Instruction6502.init(opCode, CpuOp.JSR, AddressMode.Absolute, 3, 6),

            // LDA - Load Accumulator
            0xA9 => Instruction6502.init(opCode, CpuOp.LDA, AddressMode.Immediate, 2, 2),
            0xA5 => Instruction6502.init(opCode, CpuOp.LDA, AddressMode.ZeroPage, 2, 3),
            0xB5 => Instruction6502.init(opCode, CpuOp.LDA, AddressMode.ZeroPageX, 2, 4),
            0xAD => Instruction6502.init(opCode, CpuOp.LDA, AddressMode.Absolute, 3, 4),
            0xBD => Instruction6502.init(opCode, CpuOp.LDA, AddressMode.AbsoluteX, 3, 4),
            0xB9 => Instruction6502.init(opCode, CpuOp.LDA, AddressMode.AbsoluteY, 3, 4),
            0xA1 => Instruction6502.init(opCode, CpuOp.LDA, AddressMode.IndirectX, 2, 6),
            0xB1 => Instruction6502.init(opCode, CpuOp.LDA, AddressMode.IndirectY, 2, 5),

            // LDX - Load X
            0xA2 => Instruction6502.init(opCode, CpuOp.LDX, AddressMode.Immediate, 2, 2),
            0xA6 => Instruction6502.init(opCode, CpuOp.LDX, AddressMode.ZeroPage, 2, 3),
            0xB6 => Instruction6502.init(opCode, CpuOp.LDX, AddressMode.ZeroPageY, 2, 4),
            0xAE => Instruction6502.init(opCode, CpuOp.LDX, AddressMode.Absolute, 3, 4),
            0xBE => Instruction6502.init(opCode, CpuOp.LDX, AddressMode.AbsoluteY, 3, 4),

            // LDY - Load Y
            0xA0 => Instruction6502.init(opCode, CpuOp.LDY, AddressMode.Immediate, 2, 2),
            0xA4 => Instruction6502.init(opCode, CpuOp.LDY, AddressMode.ZeroPage, 2, 3),
            0xB4 => Instruction6502.init(opCode, CpuOp.LDY, AddressMode.ZeroPageX, 2, 4),
            0xAC => Instruction6502.init(opCode, CpuOp.LDY, AddressMode.Absolute, 3, 4),
            0xBC => Instruction6502.init(opCode, CpuOp.LDY, AddressMode.AbsoluteX, 3, 4),

            // LSR - Logical Shift Right
            0x4A => Instruction6502.init(opCode, CpuOp.LSR, AddressMode.Accumulator, 1, 2),
            0x46 => Instruction6502.init(opCode, CpuOp.LSR, AddressMode.ZeroPage, 2, 5),
            0x56 => Instruction6502.init(opCode, CpuOp.LSR, AddressMode.ZeroPageX, 2, 6),
            0x4E => Instruction6502.init(opCode, CpuOp.LSR, AddressMode.Absolute, 3, 6),
            0x5E => Instruction6502.init(opCode, CpuOp.LSR, AddressMode.AbsoluteX, 3, 7),

            // NOP - No Operation
            0xEA => Instruction6502.init(opCode, CpuOp.NOP, AddressMode.Implied, 1, 2),

            // NOP - No Operation (Undocumented version)
            0x1A => Instruction6502.init(opCode, CpuOp.NOP, AddressMode.Implied, 1, 2),
            0x3A => Instruction6502.init(opCode, CpuOp.NOP, AddressMode.Implied, 1, 2),
            0x5A => Instruction6502.init(opCode, CpuOp.NOP, AddressMode.Implied, 1, 2),
            0x7A => Instruction6502.init(opCode, CpuOp.NOP, AddressMode.Implied, 1, 2),
            0xDA => Instruction6502.init(opCode, CpuOp.NOP, AddressMode.Implied, 1, 2),
            0xFA => Instruction6502.init(opCode, CpuOp.NOP, AddressMode.Implied, 1, 2),

            // ORA - Logical Inclusive OR
            0x09 => Instruction6502.init(opCode, CpuOp.ORA, AddressMode.Immediate, 2, 2),
            0x05 => Instruction6502.init(opCode, CpuOp.ORA, AddressMode.ZeroPage, 2, 3),
            0x15 => Instruction6502.init(opCode, CpuOp.ORA, AddressMode.ZeroPageX, 2, 4),
            0x0D => Instruction6502.init(opCode, CpuOp.ORA, AddressMode.Absolute, 3, 4),
            0x1D => Instruction6502.init(opCode, CpuOp.ORA, AddressMode.AbsoluteX, 3, 4),
            0x19 => Instruction6502.init(opCode, CpuOp.ORA, AddressMode.AbsoluteY, 3, 4),
            0x01 => Instruction6502.init(opCode, CpuOp.ORA, AddressMode.IndirectX, 2, 6),
            0x11 => Instruction6502.init(opCode, CpuOp.ORA, AddressMode.IndirectY, 2, 5),

            // PHA - Push Accumulator
            0x48 => Instruction6502.init(opCode, CpuOp.PHA, AddressMode.Implied, 1, 4),

            // PHP - Push Processor Status
            0x08 => Instruction6502.init(opCode, CpuOp.PHP, AddressMode.Implied, 1, 4),

            // PLA - Pull Accumulator
            0x68 => Instruction6502.init(opCode, CpuOp.PLA, AddressMode.Implied, 1, 4),

            // PLP - Pull Processor Status
            0x28 => Instruction6502.init(opCode, CpuOp.PLP, AddressMode.Implied, 1, 4),

            // ROL - Roll left
            0x2A => Instruction6502.init(opCode, CpuOp.ROL, AddressMode.Accumulator, 1, 2),
            0x26 => Instruction6502.init(opCode, CpuOp.ROL, AddressMode.ZeroPage, 2, 5),
            0x36 => Instruction6502.init(opCode, CpuOp.ROL, AddressMode.ZeroPageX, 2, 6),
            0x2E => Instruction6502.init(opCode, CpuOp.ROL, AddressMode.Absolute, 3, 6),
            0x3E => Instruction6502.init(opCode, CpuOp.ROL, AddressMode.AbsoluteX, 3, 7),

            // ROR - Roll right
            0x6A => Instruction6502.init(opCode, CpuOp.ROR, AddressMode.Accumulator, 1, 2),
            0x66 => Instruction6502.init(opCode, CpuOp.ROR, AddressMode.ZeroPage, 2, 5),
            0x76 => Instruction6502.init(opCode, CpuOp.ROR, AddressMode.ZeroPageX, 2, 6),
            0x6E => Instruction6502.init(opCode, CpuOp.ROR, AddressMode.Absolute, 3, 6),
            0x7E => Instruction6502.init(opCode, CpuOp.ROR, AddressMode.AbsoluteX, 3, 7),

            // RTI - Return from Interrupt
            0x40 => Instruction6502.init(opCode, CpuOp.RTI, AddressMode.Implied, 1, 6),

            // RTS - Return from Subroutine
            0x60 => Instruction6502.init(opCode, CpuOp.RTS, AddressMode.Implied, 1, 6),

            // SBC - Subtract with Carry
            0xE9 => Instruction6502.init(opCode, CpuOp.SBC, AddressMode.Immediate, 2, 2),
            0xE5 => Instruction6502.init(opCode, CpuOp.SBC, AddressMode.ZeroPage, 2, 3),
            0xF5 => Instruction6502.init(opCode, CpuOp.SBC, AddressMode.ZeroPageX, 2, 4),
            0xED => Instruction6502.init(opCode, CpuOp.SBC, AddressMode.Absolute, 3, 4),
            0xFD => Instruction6502.init(opCode, CpuOp.SBC, AddressMode.AbsoluteX, 3, 4),
            0xF9 => Instruction6502.init(opCode, CpuOp.SBC, AddressMode.AbsoluteY, 3, 4),
            0xE1 => Instruction6502.init(opCode, CpuOp.SBC, AddressMode.IndirectX, 2, 6),
            0xF1 => Instruction6502.init(opCode, CpuOp.SBC, AddressMode.IndirectY, 2, 5),

            // SEC - Set Carry Flag
            0x38 => Instruction6502.init(opCode, CpuOp.SEC, AddressMode.Implied, 1, 2),

            // SED - Decimal Flag
            //0x18 => Instruction6502.init(opCode, CpuOp.SED, AddressMode.Implied, 1, 2),

            // SEI - Set Interrupt Flag
            0x78 => Instruction6502.init(opCode, CpuOp.SEI, AddressMode.Implied, 1, 2),

            // STA - Store Accumulator
            0x85 => Instruction6502.init(opCode, CpuOp.STA, AddressMode.ZeroPage, 2, 3),
            0x95 => Instruction6502.init(opCode, CpuOp.STA, AddressMode.ZeroPageX, 2, 4),
            0x8D => Instruction6502.init(opCode, CpuOp.STA, AddressMode.Absolute, 3, 4),
            0x9D => Instruction6502.init(opCode, CpuOp.STA, AddressMode.AbsoluteX, 3, 5),
            0x99 => Instruction6502.init(opCode, CpuOp.STA, AddressMode.AbsoluteY, 3, 5),
            0x81 => Instruction6502.init(opCode, CpuOp.STA, AddressMode.IndirectX, 2, 6),
            0x91 => Instruction6502.init(opCode, CpuOp.STA, AddressMode.IndirectY, 2, 6),

            // STX - Store X
            0x86 => Instruction6502.init(opCode, CpuOp.STX, AddressMode.ZeroPage, 2, 3),
            0x96 => Instruction6502.init(opCode, CpuOp.STX, AddressMode.ZeroPageY, 2, 4),
            0x8E => Instruction6502.init(opCode, CpuOp.STX, AddressMode.Absolute, 3, 4),

            // STY - Store Y
            0x84 => Instruction6502.init(opCode, CpuOp.STY, AddressMode.ZeroPage, 2, 3),
            0x94 => Instruction6502.init(opCode, CpuOp.STY, AddressMode.ZeroPageX, 2, 4),
            0x8C => Instruction6502.init(opCode, CpuOp.STY, AddressMode.Absolute, 3, 4),

            // TAX - Transfer Accumulator to X
            0xAA => Instruction6502.init(opCode, CpuOp.TAX, AddressMode.Implied, 1, 2),

            // TAY - Transfer Accumulator to Y
            0xA8 => Instruction6502.init(opCode, CpuOp.TAY, AddressMode.Implied, 1, 2),

            // TSX - Transfer Stack Pointer to X
            0xBA => Instruction6502.init(opCode, CpuOp.TSX, AddressMode.Implied, 1, 2),

            // TXA - Transfer X to Accumulator
            0x8A => Instruction6502.init(opCode, CpuOp.TXA, AddressMode.Implied, 1, 2),

            // TXS - Transfer X to Stack Pointer
            0x9A => Instruction6502.init(opCode, CpuOp.TXS, AddressMode.Implied, 1, 2),

            // TYA - Transfer Y to Accumulator
            0x98 => Instruction6502.init(opCode, CpuOp.TYA, AddressMode.Implied, 1, 2),

            // ....
            else => EmuError.UnknownOp, // Err(format!("Unknown op code: {}", op_code)),
        };
    }
};



test "sanity checks" {
    try std.testing.expect(isStore(CpuOp.STA));
    try std.testing.expect(!isStore(CpuOp.LDA));

    try std.testing.expectEqual(
        Instruction6502.fromOpCode(0x69), 
        Instruction6502.init(0x69, CpuOp.ADC, AddressMode.Immediate, 2, 2)
    );
}

