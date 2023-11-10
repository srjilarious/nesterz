// zig fmt: off
const std = @import("std");
const emu = @import("./emu.zig");

pub const CpuState = emu.Cpu6502State;
pub const Instruction = emu.Instruction6502;
pub const ReadWriteState = emu.ReadWriteState;
pub const CpuOp = emu.CpuOp;
pub const AddressMode = emu.AddressMode;
pub const CpuFlags = emu.CpuFlags;

const StackBase: u16 = 0x100;

const SubResult = struct {
    val: u8,
    carry: bool,
    overflow: bool,

    fn init(minuend: u8, subtrahend: u8, carry: bool) SubResult {
        const res: u16 = minuend +% ~subtrahend +% @as(u8, carry);
        const val: u8 = @intCast(res);
        const overflow = (minuend ^ val) & (subtrahend ^ val) & 0x80 != 0;
        return .{ .val = val, .carry = (res & 0x100) != 0, .overflow = overflow };
    }
};

pub const Cpu6502 = struct {
    a: u8,
    x: u8,
    y: u8,
    pc: u16,
    sp: u8,
    status: u8,

    addrBus: u16,
    dataBus: u8,

    internalAddr: u16,
    workingVal: u16,
    shouldFetch: bool,

    busState: ReadWriteState,
    procState: CpuState,

    currInst: Instruction,
    currCycle: u8,
    cyclesLeft: u8,

    pub fn init() Cpu6502 {
        return .{
            .a = 0,
            .x = 0,
            .y = 0,
            .pc = 0,
            .sp = 0,
            .status = @intFromEnum(CpuFlags.Empty),
            .addrBus = 0,
            .dataBus = 0,
            .internalAddr = 0,
            .workingVal = 0,
            .shouldFetch = false,
            .busState = ReadWriteState.HighImpedance,
            .procState = CpuState.Startup,
            .currInst = .{
                .opCode = 0,
                .op = CpuOp.NOP,
                .mode = AddressMode.Indirect,
                .numBytes = 0,
                .numCycles = 3,
            },
            .currCycle = 0,
            .cyclesLeft = 0,
        };
    }

    pub fn tick(self: *Cpu6502) !void {
        self.shouldFetch = true;
        switch(self.procState) {
            CpuState.Startup => {
                if(self.currCycle == 0) {
                    self.pc = 0xfffe;
                    self.currCycle += 1;
                }
                else if(self.currCycle == 1) {
                    self.internalAddr = @as(u16, self.dataBus);
                    self.currCycle += 1;
                }
                else if(self.currCycle == 2) {
                    self.internalAddr |= @as(u16, self.dataBus) << 8;
                    self.pc = self.internalAddr;
                    self.procState = CpuState.Normal;
                    self.currCycle = 0;
                }
                
                self.fetchNext();
            },
            CpuState.Normal => {
                if(self.currCycle == 0) {
                    self.currInst = try Instruction.fromOpCode(self.dataBus);
                    self.cyclesLeft = self.currInst.numCycles;
                }

                self.shouldFetch = true;
                self.busState = ReadWriteState.HighImpedance;

                self.handleAdressMode();
                if(self.isOnExecCycle() or emu.isStack(self.currInst.op)) {
                    self.handleInstExec();
                }

                self.currCycle += 1;
                self.cyclesLeft -= 1;
                
                if(self.cyclesLeft == 0) {
                    self.currCycle = 0;
                }

                if(self.shouldFetch) {
                    self.fetchNext();
                }
            },
            CpuState.Halted => {
                // Do nothing.
            }
        }
    }

    pub fn reset(self: *Cpu6502) void {
        self.procState = CpuState.Startup;
        self.currCycle = 0;
        self.cyclesLeft = 3;
    }

    fn fetchNext(self: *Cpu6502) void {
        self.addrBus = self.pc;
        self.busState = ReadWriteState.Read;
        self.pc = self.pc +% 1;
    }

    fn handleAdressMode(self: *Cpu6502) void {
        switch(self.currInst.mode) {
            AddressMode.Accumulator => {
                if(self.currCycle == 0) {
                    self.workingVal = @as(u16, self.a);
                    self.shouldFetch = false;
                } else if(self.currCycle == 1) {
                    self.a = @truncate(self.workingVal);
                }
                else {
                    @panic("Unexpected cycle!");
                }
            },
            AddressMode.Implied => {
                if(self.currCycle < self.currInst.numCycles - 1) {
                    self.shouldFetch = false;
                }
            },
            AddressMode.Immediate => {
                self.workingVal = @as(u16, self.dataBus);
            },
            AddressMode.ZeroPage => {
                if(self.currCycle == 1) {
                    self.shouldFetch = false;
                    self.internalAddr = self.dataBus;
                    if(!emu.isStore(self.currInst.op)) {
                        self.addrBus = @as(u16, self.dataBus);
                        self.busState = ReadWriteState.Read;
                    }
                }
                else if(self.currCycle == 2) {
                    self.workingVal = self.dataBus;
                    if(emu.storesBackValue(self.currInst.op)) {
                        self.shouldFetch = false;
                    }
                }
                else if(self.currCycle == 3) {
                    self.shouldFetch = false;
                    self.addrBus = self.internalAddr;
                    self.dataBus = @truncate(self.workingVal);
                    self.busState = ReadWriteState.Write;
                }
            },
            // AddressMode.ZeroPageX or AddressMode.ZeroPageY => {
            //     
            // },
            // AddressMode.Absolute => {
            //     
            // },
            // AddressMode.AbsoluteX or AddressMode.AbsoluteY => {
            //     
            // },
            // AddressMode.Relative => {
            //     
            // },
            // AddressMode.Indirect => {
            //     
            // },
            else => {
                @panic("Unimplemented address mode!");
            },
        }
    }

    fn isOnExecCycle(self: *Cpu6502) bool {
        if(emu.isStore(self.currInst.op)) {
            return self.currCycle == self.currInst.numCycles - 2;
        }

        return switch(self.currInst.mode) {
            AddressMode.Accumulator => self.currCycle == 0,
            AddressMode.Implied => {
                return switch(self.currInst.op) {
                    CpuOp.RTS, CpuOp.RTI, CpuOp.BRK => self.currCycle >= 1,
                    // CpuOp.RTI=> self.currCycle >= 1,
                    // CpuOp.BRK => self.currCycle >= 1,
                    else => self.currCycle == 1,
                };
            },
            AddressMode.Immediate => self.currCycle == 1,
            AddressMode.ZeroPage => self.currCycle == 2,
            AddressMode.ZeroPageX, AddressMode.ZeroPageY => self.currCycle == 3,
            AddressMode.Relative => self.currCycle == 1,
            AddressMode.Absolute => {
                return switch(self.currInst.op) {
                    CpuOp.JMP, CpuOp.JSR  => self.currCycle == 2, 
                    // CpuOp.JSR => self.currCycle == 2,
                    else => self.currCycle == 3,
                };
            },
            AddressMode.AbsoluteX, AddressMode.AbsoluteY => self.currCycle == 3,
            AddressMode.IndirectX, AddressMode.IndirectY => self.currCycle == 4,
            AddressMode.Indirect => self.currCycle == 4,
        };
    }

    pub fn getFlag(self: *Cpu6502, flag: CpuFlags) bool {
        return (self.status & @intFromEnum(flag) != 0x0);
    }

    pub fn setFlag(self: *Cpu6502, flag: CpuFlags, val: bool) void {
        const b : u8 = @intFromEnum(flag);
        if(val) {
            self.status |= b;
        }
        else {
            self.status &= ~b;
        }
    }

    fn checkZeroFlag(self: *Cpu6502, val: u8) void {
        self.setFlag(CpuFlags.Zero, val == 0);
    }

    fn checkNegativeFlag(self: *Cpu6502, val: u8) void {
        self.setFlag(CpuFlags.Negative, (val & 0x80) != 0);
    }

    fn handleInstExec(self: *Cpu6502) void {
        switch(self.currInst.op) {
            CpuOp.ADC => {
                var result: u16 = @as(u16, self.a) +% self.workingVal + @intFromBool(self.getFlag(CpuFlags.Carry));
                self.a = @truncate(result);
                self.checkZeroFlag(self.a);
                self.checkNegativeFlag(self.a);
            },
            CpuOp.AND => {
                self.a = self.a & @as(u8, @truncate(self.workingVal));
                self.checkZeroFlag(self.a);
                self.checkNegativeFlag(self.a);
            },
            CpuOp.ASL => {
                self.workingVal = self.workingVal << 1;
                self.setFlag(CpuFlags.Carry, (self.workingVal & 0x100) != 0);
                self.checkZeroFlag(@truncate(self.workingVal));
                self.checkNegativeFlag(@truncate(self.workingVal));
            },
            CpuOp.LDA => {
                self.a = self.dataBus;
            },
            CpuOp.LDX => {
                self.x = self.dataBus;
            },
            CpuOp.LSR => {
                self.setFlag(CpuFlags.Carry, (self.workingVal & 0x1) != 0);
                self.workingVal = (@as(u8, @truncate(self.workingVal)) >> 1);
                self.checkZeroFlag(@truncate(self.workingVal));
                self.checkNegativeFlag(@truncate(self.workingVal));
            },
            CpuOp.LDY => {
                self.y = self.dataBus;
            },
            CpuOp.NOP => {},
            CpuOp.ORA => {
                self.a = self.a | @as(u8, @truncate(self.workingVal));
            },
            else => {
                @panic("Unhandled instruction!");
            }
        }
    }
};

