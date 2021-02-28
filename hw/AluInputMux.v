`timescale 1ns/1ps

// # Alu Input Selection Table
// ____________________________________________________________
// |            |                                             |
// | ALU Source | Description                                 |
// |------------|---------------------------------------------|
// |     3'b000 | Zero                                        |
// |     3'b001 | Current instruction address (PC) plus four  |
// |     3'b010 | Current instruction address (PC)            |
// |     3'b011 | Register data                               |
// |     3'b100 | Sign-extended 12-bit instruction immediate  |
// |     3'b101 | Zero-padded 20-bit instruction immediate    |
// |     3'b110 | Jump offset (JAL offset, precisely)         |
// |     3'b111 | Branch offset                               |
// |____________|_____________________________________________|
module AluInputMux(
  input [2:0] src,

  input [31:0] instr_addr,
  input [31:0] instr,
  input [31:0] rs_data,

  output [31:0] data
);

  wire sign = instr[31];

  wire [31:0] imm12 = { {20{ sign }}, instr[31:20]             };
  wire [31:0] imm20 = {               instr[31:12], {12'b0 } };

  wire [31:0] branch_offset = { {20{ instr[31] }},     instr[7], instr[30:25],  instr[11:8], 1'b0 };
  wire [31:0] jump_offset   = { {12{ instr[31] }}, instr[19:12],    instr[20], instr[30:21], 1'b0 };

  assign data = 
    src == 3'b000 ? 0 :
    src == 3'b001 ? instr_addr + 4 :
    src == 3'b010 ? instr_addr :
    src == 3'b011 ? rs_data :
    src == 3'b100 ? imm12 :
    src == 3'b101 ? imm20 :
    src == 3'b110 ? jump_offset :
    src == 3'b111 ? branch_offset :
    32'bX;

endmodule