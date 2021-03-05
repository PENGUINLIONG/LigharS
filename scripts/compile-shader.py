#! /usr/bin/python
from os import system, mkdir
from sys import argv

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
exit_code = system(COMPILE_CMD)
assert exit_code == 0, "compilation failed"


# 2. Assembly Decoration

asm = None
with open(ASM_PATH) as f:
    asm = f.read()

PRE_DECO = """
	.text
	.globl _start
_start:
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
    decorated_asm = asm.replace(".text", PRE_DECO, 1) + POST_DECO
    f.write(decorated_asm)


# 3. Machine Code Generation

ASSEMBLE_CMD = ' '.join([
  "clang",
  "--target=riscv32",
  "-march=rv32imf",
  "-c", ASM_DECO_PATH,
  "-o", OUT_PATH,
])

print(ASSEMBLE_CMD)
exit_code = system(ASSEMBLE_CMD)
assert exit_code == 0, "assembly failed"


# 4. Machine Code Decoration

obj = None
with open(OUT_PATH, 'rb') as f:
    obj = f.read()

beg = obj.find(bytes([0xef, 0xbe, 0xad, 0xde]))
end = obj.find(bytes([0xef, 0xbe, 0xad, 0xde]), beg + 4)

print(f"found program text from {beg:08x} to {end:08x}")
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
def set_entry_fn(entry_fn):
    exit_code = system(f"objdump -t ./tmp/min-reprod.o | grep {entry_fn} > tmp/objdump.log")
    assert exit_code == 0, "objdump failed"
    entry_offset = None
    with open("tmp/objdump.log") as f:
      line = f.readline().strip()
      assert len(line) != 0, f"failed to locate entry point {entry_fn}"
      entry_offset = int(line.split()[0], 16)
    imm20 = ((entry_offset - 1 + (1 << 12)) >> 12) << 12
    words[9] = 0b00000000000000000000_00010_0110111 + imm20 # lui
    words[10] = 0b000000000000_00001_000_00001_1100111 + (((entry_offset - imm20) & 0xfff) << 20) # jalr


# Set-up stack pointers and launch parameters
set_stack_ptr(4096)
for i, arg in enumerate(argv[2:]):
  set_param(i, int(arg))
# For some reason `clang` simply fails to inject the correct address for the
# jump, so we force the instructions instead.
set_entry_fn(argv[1])

assert words[0] != 0xdeadbeef, "must set the stack pointer"



# 5. Verilog Generation

def word2instr(word):
    return f"`i(32'h{word:08x});"

instrs = []
for word in words:
    instrs += [word2instr(word)]

OUTPUT_VERILOG = """`timescale 1ns/1ps

`define MEM_LIKE_MODULE .clk(clk), .reset(reset),
`define COMB_ONLY_MODULE

`define i(xinstr) data_mem.inner[instr_idx] = xinstr; instr_idx = instr_idx + 1;

module tb_Riscv();
  reg clk, reset;

  wire [31:0] instr_addr;
  wire [31:0] instr;

  wire [31:0] data_addr;
  wire [31:0] mem_read_data;
  wire [31:0] mem_write_data;
  wire should_read_mem;
  wire should_write_mem;

  DataMemory data_mem(`MEM_LIKE_MODULE
    // in
    .instr_addr(instr_addr),
    .data_addr(data_addr),
    .should_write(should_write_mem),
    .write_data(mem_write_data),
    // out
    .instr(instr),
    .read_data(mem_read_data)
  );

  wire [31:0] return_value = uut.reg_file.inner[10];

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

  reg clk_en;
  integer instr_idx;
  initial begin
    clk = 0;
    clk_en = 0;
    reset = 1; #12 reset = 0;
    clk_en = 1;
    instr_idx = 0;
    // Initialize the instruction memory with instruction data.

""" + '\n'.join(instrs) + """

    // Execute until the instruction memory is out of instructions.
    while (1) begin
      #5;
      clk = ~clk & clk_en;

      if (!reset && uut.pc.pc >= instr_idx * 4) begin
        // Terminate the program here.
        $display("THREAD FINISHED RUNNING: %m returned %d", return_value);
        clk_en = 0;
        $finish;
      end

      if (clk) begin
        $display("ISSUEING INSTRUCTION: %b %h %b", instr[31:7], instr[6:2], instr[1:0]);
      end
    end
  end

endmodule
"""

with open(VERILOG_PATH, "w") as f:
    f.truncate(0)
    f.write(OUTPUT_VERILOG)
