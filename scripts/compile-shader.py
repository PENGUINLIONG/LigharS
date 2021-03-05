#! /usr/bin/python
from os import system, mkdir
from sys import argv

SRC_NAME      = argv[1]
ENTRY_FN_NAME = argv[2]
THREAD_ARGS   = argv[3:]

SRC_PATH      = f"./assets/{SRC_NAME}.cpp"
ASM_PATH      = f"./tmp/{SRC_NAME}.s"
ASM_DECO_PATH = f"./tmp/{SRC_NAME}.decorated.s"
OUT_PATH      = f"./tmp/{SRC_NAME}.o"
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
  f"-main-file-name assets/{SRC_NAME}.cpp",
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

#print(COMPILE_CMD)
exit_code = system(COMPILE_CMD)
assert exit_code == 0, "compilation failed"

# 2. Assembly Decoration

asm = None
with open(ASM_PATH) as f:
    asm = f.read()

PRE_DECO = f"""
	.text
	.globl _start
_start:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	lui ra, %hi({ENTRY_FN_NAME})
	jalr ra, ra, %lo({ENTRY_FN_NAME})
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

#print(ASSEMBLE_CMD)
exit_code = system(ASSEMBLE_CMD)
assert exit_code == 0, "assembly failed"


# 4. Extract Command Buffer Content

def extract_section_table():
    exit_code = system(f"objdump -h {OUT_PATH} > tmp/{ENTRY_FN_NAME}.sec.log")
    assert exit_code == 0, "cannot dump section table from compiled object"

    lines = None
    with open(f"tmp/{ENTRY_FN_NAME}.sec.log") as f:
        lines = f.readlines()[5::2]

    section_offset_map = { "*ABS*": 0 }
    section_size_map   = { "*ABS*": 0 }
    for line in lines:
        segs   = line.strip().split()
        idx    = segs[0]
        name   = segs[1]
        size   = int(segs[2], 16)
        offset = int(segs[5], 16)

        section_offset_map[name] = offset
        section_size_map[name]   = size
        print(f"discovered section {name}:\toffset={offset}, size={size}")

    return section_offset_map, section_size_map

def extract_cmdbuf_content(section_offset_map, section_size_map, obj):
    text_offset  = section_offset_map[".text"]  if ".text"  in section_offset_map else 0
    sdata_offset = section_offset_map[".sdata"] if ".sdata" in section_offset_map else 0
    text_size  = section_size_map[".text"]  if ".text"  in section_size_map else 0
    sdata_size = section_size_map[".sdata"] if ".sdata" in section_size_map else 0
    assert text_size != 0, "no instruction to run in this shader"

    text_content  = obj[text_offset:(text_offset + text_size)]
    sdata_content = obj[sdata_offset:(sdata_offset + sdata_size)]
    content = text_content + sdata_content
    assert len(content) % 4 == 0, f"command buffer size must align to 4, but is {len(content)}"

    w0s = content[0::4]
    w1s = content[1::4]
    w2s = content[2::4]
    w3s = content[3::4]
    cmdbuf = [(w0s[i] << 0) + (w1s[i] << 8) + (w2s[i] << 16) + (w3s[i] << 24) for i in range(len(content) // 4)]
    print(f"collected command buffer of {len(cmdbuf)} words")

    return cmdbuf

obj = None
with open(OUT_PATH, 'rb') as f:
    obj = f.read()

section_offset_map, section_size_map = extract_section_table()
cmdbuf = extract_cmdbuf_content(section_offset_map, section_size_map, obj)


# 5. Offline Relocation

# Usually this is done by library loaders of operating systems, but as long as
# we are just compiling for the binary code, we can apply the relocation offline
# here. But sadly there seems no existing tool to save such labor.

def extract_symbol_table(section_size_map):
    exit_code = system(f"objdump -t {OUT_PATH} > tmp/{ENTRY_FN_NAME}.sym.log")
    assert exit_code == 0, "cannot dump symbol table from compiled object"

    lines = None
    with open(f"tmp/{ENTRY_FN_NAME}.sym.log") as f:
        lines = f.readlines()[4:]

    symbol_map = { "*ABS*": ("*ABS*", 0) }
    for line in lines:
        segs = line.strip().split()
        if len(segs) == 0:
            continue
        if len(segs) == 5:
            segs.insert(2, '')
        offset = int(segs[0], 16)
        section = segs[3]
        name = segs[-1]

        symbol_map[name] = (section, offset)
        print(f"discovered symbol {name}\t@{section}+{offset}")

    return symbol_map

def map_symbol_offsets(section_size_map, symbol_map):
    text_size  = section_size_map[".text"]  if ".text"  in section_size_map else 0
    sdata_size = section_size_map[".sdata"] if ".sdata" in section_size_map else 0

    assert text_size != 0, "no instruction to run in this shader"

    text_offset  = 0
    sdata_offset = text_size
    symbol_offset_map = {}
    for symbol, (section, offset) in symbol_map.items():
        if section == "*ABS*":
            symbol_offset_map[symbol] = offset
        elif section == ".text":
            symbol_offset_map[symbol] = text_offset + offset
        elif section == ".sdata":
            symbol_offset_map[symbol] = sdata_offset + offset
        else:
            assert False, f"unsupported data section {section}"

    return symbol_offset_map

def relocate_symbols(symbol_offset_map, words):
    exit_code = system(f"objdump -r {OUT_PATH} > tmp/{ENTRY_FN_NAME}.relo.log")
    assert exit_code == 0, "cannot dump relocation table from entry point"

    lines = None
    with open(f"tmp/{ENTRY_FN_NAME}.relo.log") as f:
        lines = f.readlines()[5:]

    for line in lines:
        segs = line.strip().split()
        if len(segs) == 0:
            continue

        instr_offset = int(segs[0], 16)
        symbol = segs[2]

        if symbol == "*ABS*":
            print(f"ignored relocation of absolute base at {instr_offset}, which is already zero")

        assert instr_offset % 4 == 0, f"referer offset should align to 4 but is {instr_offset}"
        assert symbol in symbol_offset_map, f"unknown symbol '{symbol}' referred by 0x{instr_offset:08x}"

        symbol_offset = symbol_offset_map[symbol]
        imm20 = (symbol_offset - 1 + (1 << 11)) >> 12
        imm12 = (symbol_offset - (imm20 << 12)) & 0xfff

        print(imm20, imm12)

        word = words[instr_offset // 4]
        opcode = (word >> 2) & 0b11111
        if opcode == 0x0D or opcode == 0x05:
            # lui, auipc
            word += imm20 << 12
        elif opcode == 0x04:
            # addi, or other adder
            word += imm12 << 20
        elif opcode == 0x1b:
            # jal
            a_imm20 = imm20 >> 19
            b_imm20 = imm20 & 0b1111111111
            c_imm20 = (imm20 >> 10) & 1
            d_imm20 = (imm20 >> 11) & 0b11111111
            word += (a_imm20 << 31) | (b_imm20 << 21) | (c_imm20 << 20) | (d_imm20 << 12)
        elif opcode == 0x19:
            # jalr
            word += imm12 << 20
        elif opcode == 0x00 or opcode == 0x01:
            # lw, flw
            word += imm12 << 20
        elif opcode == 0x08:
            # sw
            upper_imm12 = imm12 >> 5
            lower_imm12 = imm12 & 0b11111
            word += (upper_imm12 << 20) | (lower_imm12 << 2)
        else:
            assert False, f"unsupported referer instruction with opcode 0x{opcode:02x} at 0x{instr_offset:08x} to {symbol}"

        print(f"relocated reference to '{symbol}'\t({symbol_offset:08x}) by {instr_offset:08x}")
        words[instr_offset // 4] = word

symbol_map = extract_symbol_table(section_size_map)
symbol_offset_map = map_symbol_offsets(section_size_map, symbol_map)
relocate_symbols(symbol_offset_map, cmdbuf)


# 6. Machine Code Decoration

# Set-up stack pointers and launch parameters.

def param2word(iparam, value):
    assert iparam < 8, "can have at most 8 parameters"
    assert value >= -2048 and value <= 2047, "valid param value sits between -128 and 127"
    return 0b00000000_00000_000_00000_0010011 + (value << 20) + ((10 + iparam) << 7) # addi
def stack_ptr2word(value):
    assert value % (1 << 12) == 0, "base stack pointer must align to 4KB (4096B)"
    assert (value >> 32) == 0, "stack pointer is too far away"
    return 0b00000000000000000000_00010_0110111 + value # lui
def set_param(cmdbuf, iparam, value):
    cmdbuf[iparam + 1] = param2word(iparam, value)
def set_stack_ptr(cmdbuf, value):
    cmdbuf[0] = stack_ptr2word(value)
def set_entry_fn(symbol_offset_map):
    entry_offset = symbol_offset_map[ENTRY_FN_NAME]
    imm20 = ((entry_offset - 1 + (1 << 12)) >> 12) << 12
    cmdbuf[9] = 0b00000000000000000000_00010_0110111 + imm20 # lui
    cmdbuf[10] = 0b000000000000_00001_000_00001_1100111 + (((entry_offset - imm20) & 0xfff) << 20) # jalr

set_stack_ptr(cmdbuf, 4096)
for i, arg in enumerate(THREAD_ARGS):
    set_param(cmdbuf, i, int(arg))
set_entry_fn(symbol_offset_map)

assert cmdbuf[0] != 0xdeadbeef, "must set the stack pointer"


# 7. Verilog Generation

def word2instr(word):
    s = f"`i(32'b{word:032b});"
    a = s[:-14]
    b = s[-14:-9]
    c = s[-9:-4]
    d = s[-4:]
    return '_'.join([a, b, c, d])

instrs = []
for i, word in enumerate(cmdbuf):
    if i == 12:
        instrs += ["// Main text starts from here."]
    instrs += [word2instr(word) + f" // @ 0x{i * 4:08x}"]

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
  reg in_entry;
  integer instr_idx;
  initial begin
    clk = 0;
    clk_en = 0;
    in_entry = 0;
    reset = 1; #12 reset = 0;
    clk_en = 1;
    instr_idx = 0;
    // Initialize the instruction memory with instruction data.

""" + '\n'.join(instrs) + """

    // Execute until the instruction memory is out of instructions.
    while (1) begin
      #5;
      clk = ~clk & clk_en;

      // That's the instruction of infinite loop.
      if (!reset && uut.pc.pc == 11 * 4) begin
        // Terminate the program here.
        $display("");
        $display("> THREAD FINISHED RUNNING: %m returned %d", return_value);
        $display("");
        clk_en = 0;
        $finish;
      end

      if (~clk) begin
        if (uut.pc.pc > 11 * 4 & ~in_entry) begin
          $display("THREAD ENTERED ENTRY POINT");
          in_entry = 1;
        end

        $display("ISSUEING INSTRUCTION: %b %h %b @ %h", instr[31:7], instr[6:2], instr[1:0], instr_addr);
      end
    end
  end

endmodule
"""

with open(VERILOG_PATH, "w") as f:
    f.truncate(0)
    f.write(OUTPUT_VERILOG)
