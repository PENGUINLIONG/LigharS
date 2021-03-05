`timescale 1ns/1ps

// # Branch-to-take Selection Table
// ___________________________________________________________
// |           |                                             |
// | Branch OP | Description                                 |
// |-----------|---------------------------------------------|
// |     2'b00 | Current instruction address plus 4 (PC + 4) |
// |     2'b01 | Take branch when ALU reports non-zero       |
// |     2'b10 | Take branch when ALU reports zero           |
// |     2'b11 | Always take branch (jump instructions)      |
// |___________|_____________________________________________|
module BranchUnit(
  input [1:0] branch_op,
  input [31:0] branch_base_data,
  input [31:0] branch_offset_data,
  input [31:0] instr_addr,
  input alu_res_is_zero,

  output [31:0] next_pc
);

  wire take_branch = (branch_op[0] & ~alu_res_is_zero) | (branch_op[1] & alu_res_is_zero);

  assign next_pc = take_branch ? branch_base_data + branch_offset_data : instr_addr + 4;

endmodule
