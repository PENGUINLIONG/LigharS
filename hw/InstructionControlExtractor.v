`timescale 1ns/1ps

module InstructionControlExtractor(
  input [31:0] instr,

  output reg should_read_mem,
  output reg should_write_mem,
  output reg should_write_reg,
  output reg should_branch,
  output reg should_jump,


  output [4:0] rs1_addr,
  output [4:0] rs2_addr,
  output [4:0] rd_addr,

  output reg [2:0] alu_a_src,
  output reg [2:0] alu_b_src
);

  assign rs1_addr = instr[19:15];
  assign rs2_addr = instr[24:20];
  assign rd_addr = instr[11:7];

  localparam ALU_SRC_ZERO      = 3'b000;
  localparam ALU_SRC_FOUR      = 3'b001;
  localparam ALU_SRC_PC        = 3'b010;
  localparam ALU_SRC_REG       = 3'b011;
  localparam ALU_SRC_IMM12     = 3'b100;
  localparam ALU_SRC_IMM20     = 3'b101;
  localparam ALU_SRC_DONT_CARE = 3'bXXX;

  always @(*) begin
    case (instr[6:2])
      // ## Memory Read Access
      //
      // A word will be extracted from address position `rs1 + imm12`.
      5'h00: begin
        should_read_mem  <= 1;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= ALU_SRC_REG;
        alu_b_src        <= ALU_SRC_IMM12;
      end
      // ## Fences
      5'h03: begin
        // FIXME: (penguinliong) Just a nop for now.
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 0;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= ALU_SRC_DONT_CARE;
        alu_b_src        <= ALU_SRC_DONT_CARE;
      end
      // ## Immediate-value Arithmetic Operations
      5'h04: begin
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= ALU_SRC_REG;
        alu_b_src        <= ALU_SRC_IMM12;
      end
      // ## Add Upper Immediate to PC
      5'h05: begin
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= ALU_SRC_PC;
        alu_b_src        <= ALU_SRC_IMM20;
      end
      // ## Memory Write Access
      //
      // A word in `rs2` will be written back to adress position `rs1 + imm12`.
      5'h08: begin
        should_read_mem  <= 0;
        should_write_mem <= 1;
        should_write_reg <= 0;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= ALU_SRC_REG;
        alu_b_src        <= ALU_SRC_IMM12;
      end
      // ## Register-register Arithmetic Operations
      5'h0c: begin
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= ALU_SRC_REG;
        alu_b_src        <= ALU_SRC_REG;
      end
      // ## Load Upper Immediate
      5'h0d: begin
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= ALU_SRC_ZERO;
        alu_b_src        <= ALU_SRC_IMM20;
      end
      // ## Branch instructions
      5'h18: begin
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 0;
        should_branch    <= 1;
        should_jump      <= 0;
        alu_a_src        <= ALU_SRC_REG;
        alu_b_src        <= ALU_SRC_REG;
      end
      // ## Jump and Link Register
      //
      // The return address will be written to `rd`.
      5'h19: begin
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 1;
        alu_a_src        <= ALU_SRC_PC;
        alu_b_src        <= ALU_SRC_FOUR;
      end
      // ## Jump and Link
      //
      // The return address will be written to `rd`.
      5'h1b: begin
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 1;
        alu_a_src        <= ALU_SRC_PC;
        alu_b_src        <= ALU_SRC_FOUR;
      end
      default: begin
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 0;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= ALU_SRC_DONT_CARE;
        alu_b_src        <= ALU_SRC_DONT_CARE;
      end
    endcase
  end

endmodule
