`timescale 1ns/1ps

// # Alu Input Selection Table
// ______________________________________________________________________
// |            |                                                       |
// | ALU Source | Description                                           |
// |------------|-------------------------------------------------------|
// |     3'b000 | Zero                                                  |
// |     3'b001 | Current instruction address (PC) plus four            |
// |     3'b010 | Current instruction address (PC)                      |
// |     3'b011 | Register data                                         |
// |     3'b100 | Sign-extended 12-bit instruction immediate            |
// |     3'b101 | Zero-padded 20-bit instruction immediate              |
// |     3'b110 | XMM register data                                     |
// |     3'b111 | Sign-extended 12-bit instruction immediate (splitted) |
// |____________|_______________________________________________________|
module AluInputMux(
  input [2:0] src,

  input [31:0] instr_addr,
  input [31:0] instr,
  input [31:0] rs_data,
  input [63:0] xs_data,

  output [31:0] data
);

  wire sign = instr[31];

  wire [31:0] imm12   = { {20{ sign }}, instr[31:20]              };
  wire [31:0] imm20   = {               instr[31:12], 12'b0       };
  wire [31:0] imm12hl = { {20{ sign }}, instr[31:25], instr[11:7] };

  wire [31:0] xs_fp32;
  Q15ToFp32 xs_cvt(
    .q15_data(xs_data),
    .fp32_data(xs_fp32)
  );

  assign data = 
    src == 3'b000 ? 0 :
    src == 3'b001 ? instr_addr + 4 :
    src == 3'b010 ? instr_addr :
    src == 3'b011 ? rs_data :
    src == 3'b100 ? imm12 :
    src == 3'b101 ? imm20 :
    src == 3'b110 ? xs_fp32 :
    src == 3'b111 ? imm12hl :
    32'bX;

endmodule