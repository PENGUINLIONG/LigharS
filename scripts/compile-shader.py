#! /usr/bin/python
from os import system, mkdir

SRC_PATH      = "./assets/min-reprod.cpp"
ASM_PATH      = "./tmp/min-reprod.s"
ASM_DECO_PATH = "./tmp/min-reprod.decorated.s"
OUT_PATH      = "./tmp/min-reprod.o"
VERILOG_PATH  = "./hw/tb/tb_Riscv.v"

try:
    mkdir("tmp")
except:
    pass

# 1. Compilation

COMPILE_CMD = ' '.join([
  "clang",
  "-cc1 -S -O2",
  "-triple riscv32-unknown-unknown-elf",
  "-disable-free",
  "-disable-llvm-verifier",
  "-discard-value-names",
  "-main-file-name assets/min-reprod.cpp",
  "-mrelocation-model static",
  "-mframe-pointer=none",
  "-fmath-errno",
  "-fno-rounding-math",
  "-mconstructor-aliases",
  "-nostdsysteminc",
  "-target-feature +m",
  "-target-feature +f",
  "-target-feature +relax",
  "-target-abi ilp32",
  "-fdeprecated-macro",
  "-fno-signed-char",
  "-fgnuc-version=4.2.1",
  "-faddrsig",
  "-o", ASM_PATH,
  "-x c++",
  SRC_PATH,
])

print(COMPILE_CMD)
system(COMPILE_CMD)


# 2. Assembly Decoration

asm = None
with open(ASM_PATH) as f:
    asm = f.read()

PRE_DECO = """
	.word 3735928559
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	call ray_gen
.__end_loop:
	j .__end_loop
"""
POST_DECO = """
	.word 3735928559
"""

with open(ASM_DECO_PATH, "w") as f:
    f.write(PRE_DECO + asm + POST_DECO)


# 3. Machine Code Generation

ASSEMBLE_CMD = ' '.join([
  "clang",
  "--target=riscv32",
  "-march=rv32imf",
  "-c", ASM_DECO_PATH,
  "-o", OUT_PATH,
])

print(ASSEMBLE_CMD)
system(ASSEMBLE_CMD)


# 4. Data Memory Fill

obj = None
with open(OUT_PATH, 'rb') as f:
    obj = f.read()

beg = obj.find(bytes([0xef, 0xbe, 0xad, 0xde]))
end = obj[beg + 4:].find(bytes([0xef, 0xbe, 0xad, 0xde]))

text = obj[beg:end]


assert len(text) % 4 == 0, f"executable size must align to 4, but is {len(text)}"
NINSTR_SLOT = 3

w0s = text[0::4]
w1s = text[1::4]
w2s = text[2::4]
w3s = text[3::4]

words = [(w0s[i] << 0) + (w1s[i] << 8) + (w2s[i] << 16) + (w3s[i] << 24) for i in range(len(text) // 4)]

def param2word(iparam, value):
    assert iparam < 8, "can have at most 8 parameters"
    assert value >= -2048 and value <= 2047, "valid param value sits between -128 and 127"
    return 0b00000000_00000_000_00000_0010011 + (value << 20) + ((10 + iparam) << 7) # addi
def stack_ptr2word(value):
    assert value % (1 << 12) == 0, "base stack pointer must align to 4KB (4096B)"
    assert (value >> 32) == 0, "stack pointer is too far away"
    return 0b00000000000000000000_00010_0110111 + value # lui
def set_param(iparam, value):
    words[iparam + 1] = param2word(iparam, value)
def set_stack_ptr(value):
    words[0] = stack_ptr2word(value)

# ---- Set launch parameters. -------------------------------------------------
set_stack_ptr(4096)
set_param(0, 1)
set_param(1, 1)
set_param(2, 4)
# -----------------------------------------------------------------------------

assert words[0] != 0xdeadbeef, "must set the stack pointer"

def word2instr(word):
    return f"`i(32'h{word:08x});"

instrs = []
for word in words:
    instrs += [word2instr(word)]

OUTPUT_VERILOG = """`timescale 1ns/1ps

`define MEM_LIKE_MODULE .clk(clk), .reset(reset),
`define COMB_ONLY_MODULE

`define i(xinstr) instr_mem.inner[instr_idx] = xinstr; instr_idx = instr_idx + 1;

module tb_Riscv();
  reg clk, reset;

  wire [31:0] instr_addr;
  wire [31:0] instr;

  wire [31:0] data_addr;
  wire [31:0] mem_read_data;
  wire [31:0] mem_write_data;
  wire should_read_mem;
  wire should_write_mem;

  InstructionMemory instr_mem(`COMB_ONLY_MODULE
    // in
    .addr(instr_addr),
    // out
    .instr(instr)
  );

  DataMemory data_mem(`MEM_LIKE_MODULE
    // in
    .addr(data_addr),
    .should_write(should_write_mem),
    .write_data(mem_write_data),
    // out
    .read_data(mem_read_data)
  );


  Riscv uut(`MEM_LIKE_MODULE
    // in
    .instr(instr),
    .mem_read_data(mem_read_data),
    // out
    .instr_addr(instr_addr),
    .data_addr(data_addr),
    .should_write_mem(should_write_mem),
    .should_read_mem(should_read_mem),
    .mem_write_data(mem_write_data)
  );

  always #5 clk = ~clk;

  integer instr_idx;
  always @(posedge clk) begin
    // Execute until the instruction memory is out of instructions.
    if (!reset && uut.pc.pc >= instr_idx * 4)
      uut.pc.pc = 0;
  end

  initial begin
    clk = 0;
    reset = 1; #12 reset = 0;
    instr_idx = 0;
    // Initialize the instruction memory with instruction data.

""" + '\n'.join(instrs) + """

  end

endmodule
"""

with open(VERILOG_PATH, "w") as f:
    f.truncate(0)
    f.write(OUTPUT_VERILOG)
