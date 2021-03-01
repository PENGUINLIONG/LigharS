`timescale 1ns/1ps
// In this project the modules are classified into two categories: Memory-like,
// and Combination-only.
//
// Memory-like modules are like memory components, they MUST hold their
// computation result in registers within a cycle. Memory-like components should
// be reading on the positive edge while being written on the negative edge.
//
// Combination-only modules are pure combinational circuits, they MUST NOT
// use any register to hold their result.

`define MEM_LIKE_MODULE .clk(clk), .reset(reset),
`define COMB_ONLY_MODULE

module Riscv(
  input clk,
  input reset,

  input [31:0] instr,
  input [31:0] mem_read_data,

  output [31:0] instr_addr,
  output [31:0] data_addr,
  output should_read_mem,
  output should_write_mem,
  output [31:0] mem_write_data
);

wire [31:0] next_pc;
wire [2:0] alu_a_src, alu_b_src;
wire [2:0] branch_base_src, branch_offset_src;
wire [1:0] reg_write_src, xmm_write_src, mem_write_src;
wire [3:0] alu_op;
wire [1:0] branch_op;
wire [4:0] rs1_addr, rs2_addr, rs3_addr, rd_addr;
wire [31:0] rs1_data, rs2_data;
wire [63:0] xs1_data, xs2_data, xs3_data;
wire [31:0] a_data, b_data;
wire [31:0] branch_base_data, branch_offset_data;
wire [31:0] alu_res;
wire [63:0] fpu_res;
wire should_write_reg;
wire should_write_xmm;
wire [31:0] reg_write_data;
wire [63:0] xmm_write_data;

assign data_addr = alu_res;

wire [31:0] branch_addr = branch_base_data + branch_offset_data;
wire alu_res_is_zero = alu_res == 0 ? 1 : 0;


// Components.

ProgramCounter pc(`MEM_LIKE_MODULE
  // in
  .next_pc(next_pc),
  // out
  .instr_addr(instr_addr)
);
InstructionControlExtractor instr_ctrl_extract(`COMB_ONLY_MODULE
  // in
  .instr(instr),
  // out
  .should_read_mem(should_read_mem),
  .should_write_mem(should_write_mem),
  .should_write_reg(should_write_reg),
  .rs1_addr(rs1_addr),
  .rs2_addr(rs2_addr),
  .rs3_addr(rs3_addr),
  .rd_addr(rd_addr),
  .alu_a_src(alu_a_src),
  .alu_b_src(alu_b_src),
  .reg_write_src(reg_write_src),
  .mem_write_src(mem_write_src)
);
InstructionAluOpTranslator instr_alu_op_trans(`COMB_ONLY_MODULE
  // in
  .instr(instr),
  // out
  .alu_op(alu_op)
);
InstructionBranchSelTranslator instr_branch_sel_trans(`COMB_ONLY_MODULE
  // in
  .instr(instr),
  // out
  .branch_op(branch_op),
  .branch_base_src(branch_base_src),
  .branch_offset_src(branch_offset_src)
);
RegisterFile reg_file(`MEM_LIKE_MODULE
  // in
  .read_addr1(rs1_addr),
  .read_addr2(rs2_addr),
  .write_addr(rd_addr),
  .should_write(should_write_reg),
  .write_data(reg_write_data),
  // out
  .read_data1(rs1_data),
  .read_data2(rs2_data)
);
XmmRegisterFile xmm_reg_file(`MEM_LIKE_MODULE
  // in
  .read_addr1(rs1_addr),
  .read_addr2(rs2_addr),
  .read_addr3(rs3_addr),
  .write_addr(rd_addr),
  .should_write(should_write_xmm),
  .write_data(xmm_write_data),
  // out
  .read_data1(xs1_data),
  .read_data2(xs2_data),
  .read_data3(xs3_data)
);
AluInputMux alu_a_mux(`COMB_ONLY_MODULE
  // in
  .src(alu_a_src),
  .instr_addr(instr_addr),
  .instr(instr),
  .rs_data(rs1_data),
  .xs_data(xs1_data),
  // out
  .data(a_data)
);
AluInputMux alu_b_mux(`COMB_ONLY_MODULE
  // in
  .src(alu_b_src),
  .instr_addr(instr_addr),
  .instr(instr),
  .rs_data(rs2_data),
  .xs_data(xs2_data),
  // out
  .data(b_data)
);
BranchInputMux branch_base_mux(`COMB_ONLY_MODULE
  // in
  .src(branch_base_src),
  .instr_addr(instr_addr),
  .instr(instr),
  .rs_data(rs1_data),
  // out
  .data(branch_base_data)
);
BranchInputMux branch_offset_mux(`COMB_ONLY_MODULE
  // in
  .src(branch_offset_src),
  .instr_addr(instr_addr),
  .instr(instr),
  .rs_data(rs2_data),
  // out
  .data(branch_offset_data)
);
Alu alu(`COMB_ONLY_MODULE
  // in
  .alu_op(alu_op),
  .a_data(a_data),
  .b_data(b_data),
  // out
  .alu_res(alu_res)
);
BranchUnit branch_unit(`COMB_ONLY_MODULE
  // in
  .branch_op(branch_op),
  .branch_addr(branch_addr),
  .instr_addr(instr_addr),
  .alu_res_is_zero(alu_res_is_zero),
  // out
  .next_pc(next_pc)
);
RegisterWriteMux reg_write_mux(`COMB_ONLY_MODULE
  // in
  .src(reg_write_src),
  .alu_res(alu_res),
  .mem_read_data(mem_read_data),
  // out
  .reg_write_data(reg_write_data)
);
XmmRegisterWriteMux xmm_write_mux(`COMB_ONLY_MODULE
  // in
  .src(xmm_write_src),
  .alu_res(alu_res),
  .mem_read_data(mem_read_data),
  .fpu_res(fpu_res),
  // out
  .xmm_write_data(xmm_write_data)
);
MemoryWriteMux mem_write_mux(`COMB_ONLY_MODULE
  // in
  .src(mem_write_src),
  .rs2_data(rs2_data),
  .xs2_data(xs2_data),
  // out
  .mem_write_data(mem_write_data)
);

endmodule
