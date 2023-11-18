// zig fmt: off
const std = @import("std");

const nes = @import("nesterz");
const ReadWriteState = nes.cpu.ReadWriteState;

pub const TestFunc = *const fn () error{TestExpectedEqual}!void;

const StartTestCodeAddr = 0x200;
pub const TestNes = struct {
    cpu: nes.Cpu6502,
    mem: []u8,
    allocator: *const std.mem.Allocator,
    printDebug: bool,

    pub fn init(alloc: *const std.mem.Allocator) TestNes {

        var mem = alloc.alloc(u8, 1 << 16) catch {
            @panic("OOM");
        };
        @memset(mem, 0);
        return .{ 
            .cpu = nes.Cpu6502.init(), 
            .mem = mem, 
            .allocator = alloc,
            .printDebug = false,
        };
    }

    // This initializer is used for copying a block of instructions
    // into the start position that our tests expect, and running through
    // the reset sequence until it gets to the first instruction.
    pub fn initWithTesData(alloc: *const std.mem.Allocator, code: []const u8) TestNes {
        var self = init(alloc);
        self.writeBytes(StartTestCodeAddr, code);
        self.writeBytes(0xfffe, &[_]u8 {0x0, 0x2});
        _ = self.tickInstruction();
        return self;
    }

    pub fn deinit(self: *TestNes) void {
        self.allocator.free(self.mem);
    }

    pub fn tick(self: *TestNes) void {
        if(self.printDebug) {
            std.debug.print("[{}] currInst=0x{x}, cycle={}\n", .{
                    self.cpu.procState, self.cpu.currInst.opCode, self.cpu.currCycle 
            });
        }

        self.cpu.tick();
        switch(self.cpu.busState) {
            ReadWriteState.Read => {
                self.cpu.dataBus = self.mem[self.cpu.addrBus];
                if(self.printDebug) {
                    std.debug.print("R [0x{x}] -> 0x{x}\n", .{
                        self.cpu.addrBus, self.cpu.dataBus
                    });
                }
            },
            ReadWriteState.Write => {
                if(self.printDebug) {
                    std.debug.print("W [0x{x}] <- 0x{x}\n", .{
                        self.cpu.addrBus, self.cpu.dataBus
                    });
                }
                self.mem[self.cpu.addrBus] = self.cpu.dataBus;
            },
            ReadWriteState.HighImpedance => {}
        }
    }

    pub fn tickInstruction(self: *TestNes) u32 {
        var count: u32 = 0;
        if(self.cpu.currCycle == 0) {
            self.tick();
            count += 1;
        }

        while(self.cpu.currCycle != 0) {
            self.tick();
            count += 1;
            if(count >= 9) {
                std.debug.panic(
                    "Runaway instruction caught! Opcode: 0x{x}", 
                    .{self.cpu.currInst.opCode}
                );
            }
        }

        return count;
    }

    
    pub fn writeByte(self: *TestNes, addr: u16, val: u8) void {
        self.mem[@as(usize, addr)] = val;
    }

    pub fn writeBytes(self: *TestNes, addr: u16, vals: []const u8) void {
        @memcpy(self.mem[addr..addr+vals.len], vals);
    }

    pub fn readByte(self: *TestNes, addr: u16) u8 {
        return self.mem[@as(usize, addr)];
    }

    pub fn readBytes(self: *TestNes, addr:u16, num: usize) []u8 {
        return self.mem[addr .. addr+num];
    }
};
