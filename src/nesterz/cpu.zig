// zig fmt: off
const std = @import("std");
const emu = @import("./emu.zig");

const CpuState = emu.Cpu6502State;
const Instruction = emu.Instruction6502;
const ReadWriteState = emu.ReadWriteState;
const CpuOp = emu.CpuOp;
const AddressMode = emu.AddressMode;
const CpuFlags = emu.CpuFlags;

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
    status: emu.CpuFlags,

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
            .status = CpuFlags.Empty,
            .addrBus = 0,
            .dataBus = 0,
            .internalAddr = 0,
            .workingVal = 0,
            .shouldFetch = 0,
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
                if(self.cpuCycle == 0) {
                    self.pc = 0xfffe;
                }
                else if(self.cpuCycle == 1) {
                    self.internalAddr = @as(u16, self.dataBus);
                }
                else if(self.cpuCycle == 2) {
                    self.internalAddr |= @as(u16, self.dataBus) << 8;
                    self.pc = self.internalAddr;
                    self.procState = CpuState.Normal;
                }
                else {
                    @panic("Should not be here!");
                }
            },
            CpuState.Normal => {
                if(self.cpuCycle == 0) {
                    self.currInst = try Instruction.fromOpCode(self.dataBus);
                    self.cyckesKeft - self.currInst.numCycles;
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
                
            },
            AddressMode.Implied => {
                
            },
            AddressMode.Immediate => {
                
            },
            AddressMode.ZeroPage => {
                
            },
            AddressMode.ZeroPageX or AddressMode.ZeroPageY => {
                
            },
            AddressMode.Absolute => {
                
            },
            AddressMode.AbsoluteX or AddressMode.AbsoluteY => {
                
            },
            AddressMode.Relative => {
                
            },
            AddressMode.Indirect => {
                
            },
            else => {
                @panic("Unimplemented address mode!");
            },
        }
    }
};

test "CPU test" {
    std.debug.print("Yay!\n", .{});
}
