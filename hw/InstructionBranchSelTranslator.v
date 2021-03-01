`timescale 1ns/1ps

module InstructionBranchSelTranslator(
  input [31:0] instr,

  output reg [1:0] branch_op,
  output reg [2:0] branch_base_src,
  output reg [2:0] branch_offset_src
);

  localparam BRANCH_NEVER        = 2'b00;
  localparam BRANCH_ALU_NON_ZERO = 2'b01;
  localparam BRANCH_ALU_ZERO     = 2'b10;
  localparam BRANCH_ALWAYS       = 2'b11;
  localparam BRANCH_DONT_CARE    = 2'bXX;
  
  localparam BRANCH_SRC_ZERO      = 3'b000;
  localparam BRANCH_SRC_PC_PLUS4  = 3'b001;
  localparam BRANCH_SRC_PC        = 3'b010;
  localparam BRANCH_SRC_REG       = 3'b011;
  localparam BRANCH_SRC_IMM12     = 3'b100;
  localparam BRANCH_SRC_JUMP      = 3'b101;
  localparam BRANCH_SRC_BRANCH    = 3'b110;
  localparam BRANCH_SRC_DONT_CARE = 3'bXXX;

  wire [2:0] funct3 = instr[14:12];

  always @(*) begin
    case (instr[6:2])
      // ## Branch instructions
      5'h18: begin
        case (funct3)
        3'b000:  branch_op <= BRANCH_ALU_ZERO;
        3'b001:  branch_op <= BRANCH_ALU_NON_ZERO;
        3'b100:  branch_op <= BRANCH_ALU_NON_ZERO;
        3'b101:  branch_op <= BRANCH_ALU_ZERO;
        3'b110:  branch_op <= BRANCH_ALU_NON_ZERO;
        3'b111:  branch_op <= BRANCH_ALU_ZERO;
        default: branch_op <= BRANCH_DONT_CARE;
        endcase
        branch_base_src   <= BRANCH_SRC_PC_PLUS4;
        branch_offset_src <= BRANCH_SRC_BRANCH;
      end
      // ## Jump and Link Register
      //
      // The return address will be written to `rd`.
      5'h19: begin
        branch_op         <= BRANCH_ALWAYS;
        branch_base_src   <= BRANCH_SRC_REG;
        branch_offset_src <= BRANCH_SRC_IMM12;
      end
      // ## Jump and Link
      //
      // The return address will be written to `rd`.
      5'h1b: begin
        branch_op         <= BRANCH_ALWAYS;
        branch_base_src   <= BRANCH_SRC_PC;
        branch_offset_src <= BRANCH_SRC_JUMP;
      end
      // ## Other OPs
      default: begin
        branch_op         <= BRANCH_NEVER;
        branch_base_src   <= BRANCH_SRC_ZERO;
        branch_offset_src <= BRANCH_SRC_ZERO;
      end
    endcase
  end


endmodule
