# Testing `Riscv`

The validation of this module is somehow complicated and requires multiple
stages of labor.

1. Write your assembly, validate and check the expected result on
   https://www.cs.cornell.edu/courses/cs3410/2019sp/riscv/interpreter
2. Once you got a working copy of test code, compile the code with
   `scripts/Rv32iCompiler.ipynb`. You might need a modified version of
   `riscv-assembler` to compile your RISC-V assembly on Windows.
   `https://github.com/PENGUINLIONG/riscv-assembler/tree/use-os`
3. Create a project in Xilinx Vivado, import all hardware sources in `hw` and
   simulation sources in `hw/tb`, set the testbench module as top. (At the
   moment we only need to test on `tb_Riscv.v`; the other parts are largely
   tested and are seemingly working)
4. Copy your assembly injector code from step 2 and paste them in place in the
   `initial` block.

Now you should be able to reproduce the result and extend the RISC-V core.
