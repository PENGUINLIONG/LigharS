`timescale 1ns/1ps

module InstructionControlExtractor(
  input [31:0] instr,

  output reg should_read_mem,
  output reg should_write_mem,
  output reg should_write_reg,
  output reg should_write_xmm,

  output [4:0] rs1_addr,
  output [4:0] rs2_addr,
  output [4:0] rd_addr,

  output reg [2:0] alu_a_src,
  output reg [2:0] alu_b_src,
  output reg [1:0] fpu_a_src,
  output reg [1:0] fpu_b_src,
  output reg [2:0] reg_write_src,
  output reg [1:0] xmm_write_src,
  output reg [1:0] mem_write_src
);

  assign rs1_addr = instr[19:15];
  assign rs2_addr = instr[24:20];
  assign rs3_addr = instr[31:27];
  assign rd_addr = instr[11:7];

  localparam ALU_SRC_ZERO      = 3'b000;
  localparam ALU_SRC_PC_PLUS4  = 3'b001;
  localparam ALU_SRC_PC        = 3'b010;
  localparam ALU_SRC_REG       = 3'b011;
  localparam ALU_SRC_IMM12     = 3'b100;
  localparam ALU_SRC_IMM20     = 3'b101;
  localparam ALU_SRC_XMM       = 3'b110;
  localparam ALU_SRC_DONT_CARE = 3'bXXX;

  localparam FPU_SRC_ZERO      = 3'b000;
  localparam FPU_SRC_ONE       = 3'b001;
  localparam FPU_SRC_XMM       = 3'b010;
  localparam FPU_SRC_REG_FP32  = 3'b011;
  localparam FPU_SRC_REG_U32   = 3'b100;
  localparam FPU_SRC_REG_I32   = 3'b101;
  localparam FPU_SRC_DONT_CARE = 3'bXXX;

  localparam REG_WRITE_SRC_FPU_U32   = 3'b000;
  localparam REG_WRITE_SRC_FPU_I32   = 3'b001;
  localparam REG_WRITE_SRC_ALU       = 3'b010;
  localparam REG_WRITE_SRC_MEM       = 3'b100;
  localparam REG_WRITE_SRC_FPU_FP32  = 3'b110;
  localparam REG_WRITE_SRC_DONT_CARE = 3'bXXX;

  localparam XMM_WRITE_SRC_ALU_U32   = 3'b000;
  localparam XMM_WRITE_SRC_ALU_I32   = 3'b001;
  localparam XMM_WRITE_SRC_ALU_FP32  = 3'b010;
  localparam XMM_WRITE_SRC_MEM       = 3'b100;
  localparam XMM_WRITE_SRC_FPU       = 3'b110;
  localparam XMM_WRITE_SRC_DONT_CARE = 3'bXXX;

  localparam MEM_WRITE_SRC_REG = 2'b01;
  localparam MEM_WRITE_SRC_XMM = 2'b10;
  localparam MEM_WRITE_SRC_DONT_CARE = 2'bXX;

  always @(*) begin
    case (instr[6:2])
      // ## Memory Read Access
      //
      // A word will be extracted from address position `rs1 + imm12` and stored
      // in `rd`.
      5'h00: begin
        should_read_mem        <= 1;
        should_write_mem       <= 0;
        should_write_reg       <= 1;
        should_write_xmm       <= 0;
        alu_a_src              <= ALU_SRC_REG;
        alu_b_src              <= ALU_SRC_IMM12;
        fpu_op                 <= 4'b0000;
        fpu_a_src              <= FPU_SRC_DONT_CARE;
        fpu_b_src              <= FPU_SRC_DONT_CARE;
        reg_write_src          <= REG_WRITE_SRC_MEM;
        xmm_write_src          <= XMM_WRITE_SRC_DONT_CARE;
        mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
      end
      // ## Floating-point Memory Read Access
      //
      // A word will be extracted from address position `rs1 + imm12` and stored
      // in `xd`.
      5'h01: begin
        should_read_mem        <= 1;
        should_write_mem       <= 0;
        should_write_reg       <= 0;
        should_write_xmm       <= 1;
        alu_a_src              <= ALU_SRC_REG;
        alu_b_src              <= ALU_SRC_IMM12;
        fpu_op                 <= 4'b0000;
        fpu_a_src              <= FPU_SRC_DONT_CARE;
        fpu_b_src              <= FPU_SRC_DONT_CARE;
        reg_write_src          <= REG_WRITE_SRC_DONT_CARE;
        xmm_write_src          <= XMM_WRITE_SRC_MEM;
        mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
      end
      // ## Fences
      5'h03: begin
        // FIXME: (penguinliong) Just a nop for now.
        should_read_mem        <= 0;
        should_write_mem       <= 0;
        should_write_reg       <= 0;
        should_write_xmm       <= 0;
        alu_a_src              <= ALU_SRC_DONT_CARE;
        alu_b_src              <= ALU_SRC_DONT_CARE;
        fpu_op                 <= 4'b0000;
        fpu_a_src              <= FPU_SRC_DONT_CARE;
        fpu_b_src              <= FPU_SRC_DONT_CARE;
        reg_write_src          <= REG_WRITE_SRC_DONT_CARE;
        xmm_write_src          <= XMM_WRITE_SRC_DONT_CARE;
        mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
      end
      // ## Immediate-value Arithmetic Operations
      5'h04: begin
        should_read_mem        <= 0;
        should_write_mem       <= 0;
        should_write_reg       <= 1;
        should_write_xmm       <= 0;
        alu_a_src              <= ALU_SRC_REG;
        alu_b_src              <= ALU_SRC_IMM12;
        fpu_op                 <= 4'b0000;
        fpu_a_src              <= FPU_SRC_DONT_CARE;
        fpu_b_src              <= FPU_SRC_DONT_CARE;
        reg_write_src          <= REG_WRITE_SRC_ALU;
        xmm_write_src          <= XMM_WRITE_SRC_DONT_CARE;
        mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
      end
      // ## Add Upper Immediate to PC
      5'h05: begin
        should_read_mem        <= 0;
        should_write_mem       <= 0;
        should_write_reg       <= 1;
        should_write_xmm       <= 0;
        alu_a_src              <= ALU_SRC_PC;
        alu_b_src              <= ALU_SRC_IMM20;
        fpu_op                 <= 4'b0000;
        fpu_a_src              <= FPU_SRC_DONT_CARE;
        fpu_b_src              <= FPU_SRC_DONT_CARE;
        reg_write_src          <= REG_WRITE_SRC_ALU;
        xmm_write_src          <= XMM_WRITE_SRC_DONT_CARE;
        mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
      end
      // ## Memory Write Access
      //
      // A word in `rs2` will be written back to address position `rs1 + imm12`.
      5'h08: begin
        should_read_mem        <= 0;
        should_write_mem       <= 1;
        should_write_reg       <= 0;
        should_write_xmm       <= 0;
        alu_a_src              <= ALU_SRC_REG;
        alu_b_src              <= ALU_SRC_IMM12;
        fpu_op                 <= 4'b0000;
        fpu_a_src              <= FPU_SRC_DONT_CARE;
        fpu_b_src              <= FPU_SRC_DONT_CARE;
        reg_write_src          <= REG_WRITE_SRC_DONT_CARE;
        xmm_write_src          <= XMM_WRITE_SRC_DONT_CARE;
        mem_write_src          <= MEM_WRITE_SRC_REG;
      end
      // ## Floating-point Memory Write Access
      //
      // A word in `xs2` will be written back to address position `rs1 + imm12`.
      5'h08: begin
        should_read_mem        <= 0;
        should_write_mem       <= 1;
        should_write_reg       <= 0;
        should_write_xmm       <= 0;
        alu_a_src              <= ALU_SRC_REG;
        alu_b_src              <= ALU_SRC_IMM12;
        fpu_op                 <= 4'b0000;
        fpu_a_src              <= FPU_SRC_DONT_CARE;
        fpu_b_src              <= FPU_SRC_DONT_CARE;
        reg_write_src          <= REG_WRITE_SRC_DONT_CARE;
        xmm_write_src          <= XMM_WRITE_SRC_DONT_CARE;
        mem_write_src          <= MEM_WRITE_SRC_XMM;
      end
      // ## Register-register Arithmetic Operations
      5'h0c: begin
        should_read_mem        <= 0;
        should_write_mem       <= 0;
        should_write_reg       <= 1;
        should_write_xmm       <= 0;
        alu_a_src              <= ALU_SRC_REG;
        alu_b_src              <= ALU_SRC_REG;
        fpu_op                 <= 4'b0000;
        fpu_a_src              <= FPU_SRC_DONT_CARE;
        fpu_b_src              <= FPU_SRC_DONT_CARE;
        reg_write_src          <= REG_WRITE_SRC_ALU;
        xmm_write_src          <= XMM_WRITE_SRC_DONT_CARE;
        mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
      end
      // ## Load Upper Immediate
      5'h0d: begin
        should_read_mem        <= 0;
        should_write_mem       <= 0;
        should_write_reg       <= 1;
        should_write_xmm       <= 0;
        alu_a_src              <= ALU_SRC_ZERO;
        alu_b_src              <= ALU_SRC_IMM20;
        fpu_op                 <= 4'b0000;
        fpu_a_src              <= FPU_SRC_DONT_CARE;
        fpu_b_src              <= FPU_SRC_DONT_CARE;
        reg_write_src          <= REG_WRITE_SRC_ALU;
        xmm_write_src          <= XMM_WRITE_SRC_DONT_CARE;
        mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
      end
      // ## Floating-point arithmetics
      5'h0d: begin
        casex (instr[31:27]) begin
          5'b000xx: begin // fadd.s, fsub.s, fmul.s, fdiv.s
            should_read_mem        <= 0;
            should_write_mem       <= 0;
            should_write_reg       <= 0;
            should_write_xmm       <= 1;
            alu_a_src              <= ALU_SRC_DONT_CARE;
            alu_b_src              <= ALU_SRC_DONT_CARE;
            fpu_op                 <= {2'b00, instr[28:27]};
            fpu_a_src              <= FPU_SRC_XMM;
            fpu_b_src              <= FPU_SRC_XMM;
            reg_write_src          <= REG_WRITE_SRC_DONT_CARE;
            xmm_write_src          <= XMM_WRITE_SRC_FPU;
            mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
          end
          5'h04: begin // fsgnj.s, fsgnjn.s, fsgnjx.s
            should_read_mem        <= 0;
            should_write_mem       <= 0;
            should_write_reg       <= 0;
            should_write_xmm       <= 1;
            alu_a_src              <= ALU_SRC_DONT_CARE;
            alu_b_src              <= ALU_SRC_DONT_CARE;
            fpu_op                 <= {2'b01, instr[13:12]};
            fpu_a_src              <= FPU_SRC_XMM;
            fpu_b_src              <= FPU_SRC_XMM;
            reg_write_src          <= REG_WRITE_SRC_DONT_CARE;
            xmm_write_src          <= XMM_WRITE_SRC_FPU;
            mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
          end
          5'h05: begin // fmin.s, fmax.s
            should_read_mem        <= 0;
            should_write_mem       <= 0;
            should_write_reg       <= 0;
            should_write_xmm       <= 1;
            alu_a_src              <= ALU_SRC_DONT_CARE;
            alu_b_src              <= ALU_SRC_DONT_CARE;
            fpu_op                 <= {3'b110, instr[12]};
            fpu_a_src              <= FPU_SRC_XMM;
            fpu_b_src              <= FPU_SRC_XMM;
            reg_write_src          <= REG_WRITE_SRC_DONT_CARE;
            xmm_write_src          <= XMM_WRITE_SRC_FPU;
            mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
          end
          5'h14: begin // fle.s, flt.s, feq.s
            should_read_mem        <= 0;
            should_write_mem       <= 0;
            should_write_reg       <= 1;
            should_write_xmm       <= 0;
            alu_a_src              <= ALU_SRC_DONT_CARE;
            alu_b_src              <= ALU_SRC_DONT_CARE;
            fpu_op                 <= {2'b10, instr[13:12]};
            fpu_a_src              <= FPU_SRC_XMM;
            fpu_b_src              <= FPU_SRC_XMM;
            reg_write_src          <= REG_WRITE_SRC_FPU_U32;
            xmm_write_src          <= XMM_WRITE_SRC_DONT_CARE;
            mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
          end
          5'h18: begin // fcvt.w.s, fcvt.wu.s
            should_read_mem        <= 0;
            should_write_mem       <= 0;
            should_write_reg       <= 0;
            should_write_xmm       <= 1;
            alu_a_src              <= ALU_SRC_REG;
            alu_b_src              <= ALU_SRC_ZERO;
            fpu_op                 <= 4'b0000;
            fpu_a_src              <= FPU_SRC_DONT_CARE;
            fpu_b_src              <= FPU_SRC_DONT_CARE;
            reg_write_src          <= REG_WRITE_SRC_DONT_CARE;
            xmm_write_src          <= instr[20] ? XMM_WRITE_SRC_ALU_I32 : XMM_WRITE_SRC_ALU_U32;
            mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
          end
          5'h1A: begin // fcvt.s.w, fcvt.s.wu
            should_read_mem        <= 0;
            should_write_mem       <= 0;
            should_write_reg       <= 1;
            should_write_xmm       <= 0;
            alu_a_src              <= ALU_SRC_DONT_CARE;
            alu_b_src              <= ALU_SRC_DONT_CARE;
            fpu_op                 <= 4'b0000;
            fpu_a_src              <= FPU_SRC_XMM;
            fpu_b_src              <= FPU_SRC_ZERO;
            reg_write_src          <= instr[20] ? REG_WRITE_SRC_FPU_I32 : REG_WRITE_SRC_FPU_U32;
            xmm_write_src          <= XMM_WRITE_SRC_DONT_CARE;
            mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
          end
          5'h1C: begin // fmv.x.w
            should_read_mem        <= 0;
            should_write_mem       <= 0;
            should_write_reg       <= 1;
            should_write_xmm       <= 0;
            alu_a_src              <= ALU_SRC_DONT_CARE;
            alu_b_src              <= ALU_SRC_DONT_CARE;
            fpu_op                 <= 4'b0000;
            fpu_a_src              <= FPU_SRC_XMM;
            fpu_b_src              <= FPU_SRC_ZERO;
            reg_write_src          <= REG_WRITE_SRC_FPU_FP32;
            xmm_write_src          <= XMM_WRITE_SRC_DONT_CARE;
            mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
          end
          5'h1E: begin // fmv.w.x
            should_read_mem        <= 0;
            should_write_mem       <= 0;
            should_write_reg       <= 0;
            should_write_xmm       <= 1;
            alu_a_src              <= ALU_SRC_REG;
            alu_b_src              <= ALU_SRC_ZERO;
            fpu_op                 <= 4'b0000;
            fpu_a_src              <= FPU_SRC_DONT_CARE;
            fpu_b_src              <= FPU_SRC_DONT_CARE;
            reg_write_src          <= REG_WRITE_SRC_DONT_CARE;
            xmm_write_src          <= XMM_WRITE_SRC_ALU_FP32;
            mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
          end
          default: begin
            should_read_mem        <= 0;
            should_write_mem       <= 0;
            should_write_reg       <= 0;
            should_write_xmm       <= 0;
            alu_a_src              <= ALU_SRC_DONT_CARE;
            alu_b_src              <= ALU_SRC_DONT_CARE;
            fpu_op                 <= 4'b0000;
            fpu_a_src              <= FPU_SRC_DONT_CARE;
            fpu_b_src              <= FPU_SRC_DONT_CARE;
            reg_write_src          <= REG_WRITE_SRC_DONT_CARE;
            xmm_write_src          <= XMM_WRITE_SRC_DONT_CARE;
            mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
          end
        end
      end
      // ## Branch instructions
      5'h18: begin
        should_read_mem        <= 0;
        should_write_mem       <= 0;
        should_write_reg       <= 0;
        should_write_xmm       <= 0;
        alu_a_src              <= ALU_SRC_REG;
        alu_b_src              <= ALU_SRC_REG;
        fpu_op                 <= 4'b0000;
        fpu_a_src              <= FPU_SRC_DONT_CARE;
        fpu_b_src              <= FPU_SRC_DONT_CARE;
        reg_write_src          <= REG_WRITE_SRC_DONT_CARE;
        xmm_write_src          <= XMM_WRITE_SRC_DONT_CARE;
        mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
      end
      // ## Jump and Link Register
      //
      // The return address will be written to `rd`.
      5'h19: begin
        should_read_mem        <= 0;
        should_write_mem       <= 0;
        should_write_reg       <= 1;
        should_write_xmm       <= 0;
        alu_a_src              <= ALU_SRC_PC_PLUS4;
        alu_b_src              <= ALU_SRC_ZERO;
        fpu_op                 <= 4'b0000;
        fpu_a_src              <= FPU_SRC_DONT_CARE;
        fpu_b_src              <= FPU_SRC_DONT_CARE;
        reg_write_src          <= REG_WRITE_SRC_ALU;
        xmm_write_src          <= XMM_WRITE_SRC_DONT_CARE;
        mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
      end
      // ## Jump and Link
      //
      // The return address will be written to `rd`.
      5'h1b: begin
        should_read_mem        <= 0;
        should_write_mem       <= 0;
        should_write_reg       <= 1;
        should_write_xmm       <= 0;
        alu_a_src              <= ALU_SRC_PC_PLUS4;
        alu_b_src              <= ALU_SRC_ZERO;
        fpu_op                 <= 4'b0000;
        fpu_a_src              <= FPU_SRC_DONT_CARE;
        fpu_b_src              <= FPU_SRC_DONT_CARE;
        reg_write_src          <= REG_WRITE_SRC_ALU;
        xmm_write_src          <= XMM_WRITE_SRC_DONT_CARE;
        mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
      end
      // ## Unsupported OPs
      default: begin
        should_read_mem        <= 0;
        should_write_mem       <= 0;
        should_write_reg       <= 0;
        should_write_xmm       <= 0;
        alu_a_src              <= ALU_SRC_DONT_CARE;
        alu_b_src              <= ALU_SRC_DONT_CARE;
        fpu_op                 <= 4'b0000;
        fpu_a_src              <= FPU_SRC_DONT_CARE;
        fpu_b_src              <= FPU_SRC_DONT_CARE;
        reg_write_src          <= REG_WRITE_SRC_DONT_CARE;
        xmm_write_src          <= XMM_WRITE_SRC_DONT_CARE;
        mem_write_src          <= MEM_WRITE_SRC_DONT_CARE;
      end
    endcase
  end

endmodule
