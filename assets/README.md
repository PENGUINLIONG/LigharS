# Compile Minimal Reproduction Shader

This document describes the preparation of our command buffer.

## Compile to RISC-V Assembly

On any system with a recent version of `clang` installed, run the following to generate RISC-V32IMF assembly. You should review the assembly emitted to ensure there exists no surprising instructions that we have not implemented yet. We will be using all both `M` and `F` extensions of RISC-V so make sure they have been implemented and individually tested before introducing the shader.

```bash
clang -cc1 -triple riscv32-unknown-unknown-elf -S -disable-free -disable-llvm-verifier -discard-value-names -main-file-name assets/min-reprod.cpp -mrelocation-model static -mframe-pointer=none -fmath-errno -fno-rounding-math -mconstructor-aliases -nostdsysteminc -target-feature +m -target-feature +f -target-feature +relax -target-abi ilp32 -O2 -fdeprecated-macro -fno-signed-char -fgnuc-version=4.2.1 -faddrsig -o ./assets/min-reprod.s -x c++ assets/min-reprod.cpp
```

We should add a header for the trace to start. The following snippet allows us to fill in three instructions to fill in thread parameters, i.e., current X/Y offset and the edge size of the framebuffer. The ray-generation function is then called to traverse throughout the scene. When it returns, the thread will fall in a infinite loop until the `reset` signal is pulled up, the return value regiter (`a0`) will contain our pixel color encoded in one unsigned 32-bit integer.

```asm
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
```

And we would want to mark up the end of the assembly, for a reason we would discuss later; so we need to add the following snippet at the end of the file:

```asm
	.word 3735928559
```

`3735928559` is `0xdeadbeef` in decimal. It is easy to identify while hardly colliding with normal instructions.

## Assemble to Machine Code

To generate machine code binary using the emitted assembly:

```bash
clang --target=riscv32 -march=rv32imf -c -o ./assets/min-reprod.o -c assets/min-reprod.s
```

The binary should contain a symbol table with three major functions `ray_gen`, `trace` and `traverse` without mangling.

Notice that in this way we are generating an ELF file, it's like many common file formats, it has a file header and many sections. But for the ease of processing, we don't parse the header but use two `0xdeadbeef` markers to locate the two ends of executable data.

```python
obj = None
with open("assets/min-reprod.o", 'rb') as f:
    obj = f.read()

beg = obj.find(bytes([0xef, 0xbe, 0xad, 0xde]))
end = obj[beg + 4:].find(bytes([0xef, 0xbe, 0xad, 0xde]))

print((beg, end))
text = obj[beg:end]
```

## Setup Data Memory

Now we convert the binary into Verilog codes to initialize data memory, continueing from previous Python codes.

```python
assert len(text) % 4 == 0, "executable size must align to 4"
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

# Set launch parameters.
set_stack_ptr(4096)
set_param(0, 1)
set_param(1, 1)
set_param(2, 4)

assert words[0] != 0xdeadbeef, "must set the stack pointer"

def word2instr(word):
    return f"`i(32'h{word:08x});"

instrs = []
for word in words:
    instrs += [word2instr(word)]

print('\n'.join(instrs))
```

The memory filler code will be printed out then.

## Locate the Entry Point

Although by adding the header our program should be able to enter the entry point automatically, it's still merit to double check that our workflow is producing meaningful output. We use `ray_gen` as our entry point; and you can then use `objdump` to extract the address of ray-generation function:

```bash
objdump -t ./tmp/min-reprod.o | grep ray_gen
```

The offset to `ray_gen` function head is in the first column. For the time I run this it gives `0x00000840` (with markers installed). The first `0xdeadbeef` marker starts from 52B, so I can ensure the address matches as the instruction at `0x0874` is operating on the stack pointer.

## Handy Script

All above procedures have been compiled into a single script, located at `script/compile-shader.py`. It will directly update `hw/tb/tb_Riscv.v` so that you can test it out in behavioral simulator right away.
