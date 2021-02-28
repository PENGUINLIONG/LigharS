# LigharS Hardware Implementation

This document is intended for a high level description of the architecture of
LigharS, as well as technical details.

## Fixed-point as Floating-point

LigharS treat real number processing as first-class citizen; which means LigharS
has a same throughput for real numbers as for integers. While IEEE 754
floating-point is an prevailing format for real number representation, LigharS
does not support direct processing of floating-point data. Instead, LigharS
decode and re-encode floating point numbers into signed q15.48 fixed-point
numbers for both arithmetic precision and implementation ease.

Once loaded into the execution engine, the floating-point number is processed
and stored in specialized real number register file called the XMM register
file which consists of 32 general purpose q15.48 fixed-point number XMM
registers.

The real number operations are undergone in the FPU, which stands for *Fixed-
point Processing Unit*. For each issued FPU instruction, three data are
generated or read from XMM registers. And are associated and combined to give a
final result. The processing of real number in LigharS is based on the equation
`A * B + C`. Most instructions in the `F` extension of RISC-V can be realized
with this DSP unit, and different selection of input data.

```plaintext
________________________________________________________________________
|           |                 |            |             |             |
| Operation | FPU Result      | Output Mux | Flag        | Sign Source |
|___________|_________________|____________|_____________|_____________|
| fadd.s    | + ( 1 * B ) + C | FPU Result | 0           | FPU Result  |
| fsub.s    | + ( 1 * B ) - C | FPU Result | 0           | FPU Result  |
| fmul.s    | + ( A * B ) + 0 | FPU Result | 0           | FPU Result  |
| fdiv.s    | + ( A / B ) + 0 | FPU Result | 0           | FPU Result  |
| fsgnj.s   | + ( 1 * 0 ) S C | FPU Result | 0           | !(B ^ C)    |
| fsgnjn.s  | + ( 1 * 0 ) S C | FPU Result | 0           | B ^ C       |
| fsgnjx.s  | + ( 1 * 0 ) S C | FPU Result | 0           | B           |
| fmin.s    | - ( 1 * B ) + C | C if flag  | neg         | FPU Result  |
| fmax.s    | + ( 1 * B ) - C | C if flag  | neg         | FPU Result  |
| fle.s     | - ( 1 * B ) + C | 1 if flag  | neg or zero | FPU Result  |
| flt.s     | - ( 1 * B ) + C | 1 if flag  | neg         | FPU Result  |
| feq.s     | - ( 1 * B ) + C | 1 if flag  | zero        | FPU Result  |
| fcvt.w.s  | + ( 1 * 0 ) + C | FPU Result | 0           | FPU Result  |
| fcvt.uw.s | + ( 1 * 0 ) + C | FPU Result | 0           | FPU Result  |
| fcvt.s.w  | + ( 1 * 0 ) + C | FPU Result | 0           | FPU Result  |
| fcvt.s.uw | + ( 1 * 0 ) + C | FPU Result | 0           | FPU Result  |
| fmv.w.x   | + ( 1 * 0 ) + C | FPU Result | 0           | FPU Result  |
| fmv.x.w   | + ( 1 * 0 ) + C | FPU Result | 0           | FPU Result  |
| fmadd.s   | + ( A * B ) + C | FPU Result | 0           | FPU Result  |
| fmsub.s   | + ( A * B ) - C | FPU Result | 0           | FPU Result  |
| fnmadd.s  | - ( A * B ) + C | FPU Result | 0           | FPU Result  |
| fnmsub.s  | - ( A * B ) - C | FPU Result | 0           | FPU Result  |
| flw       | DONE IN CONTROL | N/A        | N/A         | N/A         |
| fsw       | DONE IN CONTROL | N/A        | N/A         | N/A         |
| fsqrt.s   | NOT IMPLEMENTED | N/A        | N/A         | N/A         |
|___________|_________________|____________|_____________|_____________|
```
