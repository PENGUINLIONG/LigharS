`timescale 1ns/1ps

module SignedArithShiftWorkaround(
  input signed [31:0] data,
  input [4:0] shamt,
  output [31:0] res
);
  assign res =
    shamt == 5'b00000 ? { { 0{data[31]}}, data[31: 0] } :
    shamt == 5'b00001 ? { { 1{data[31]}}, data[31: 1] } :
    shamt == 5'b00010 ? { { 2{data[31]}}, data[31: 2] } :
    shamt == 5'b00011 ? { { 3{data[31]}}, data[31: 3] } :
    shamt == 5'b00100 ? { { 4{data[31]}}, data[31: 4] } :
    shamt == 5'b00101 ? { { 5{data[31]}}, data[31: 5] } :
    shamt == 5'b00110 ? { { 6{data[31]}}, data[31: 6] } :
    shamt == 5'b00111 ? { { 7{data[31]}}, data[31: 7] } :
    shamt == 5'b01000 ? { { 8{data[31]}}, data[31: 8] } :
    shamt == 5'b01001 ? { { 9{data[31]}}, data[31: 9] } :
    shamt == 5'b01010 ? { {10{data[31]}}, data[31:10] } :
    shamt == 5'b01011 ? { {11{data[31]}}, data[31:11] } :
    shamt == 5'b01100 ? { {12{data[31]}}, data[31:12] } :
    shamt == 5'b01101 ? { {13{data[31]}}, data[31:13] } :
    shamt == 5'b01110 ? { {14{data[31]}}, data[31:14] } :
    shamt == 5'b01111 ? { {15{data[31]}}, data[31:15] } :
    shamt == 5'b10000 ? { {16{data[31]}}, data[31:16] } :
    shamt == 5'b10001 ? { {17{data[31]}}, data[31:17] } :
    shamt == 5'b10010 ? { {18{data[31]}}, data[31:18] } :
    shamt == 5'b10011 ? { {19{data[31]}}, data[31:19] } :
    shamt == 5'b10100 ? { {20{data[31]}}, data[31:20] } :
    shamt == 5'b10101 ? { {21{data[31]}}, data[31:21] } :
    shamt == 5'b10110 ? { {22{data[31]}}, data[31:22] } :
    shamt == 5'b10111 ? { {23{data[31]}}, data[31:23] } :
    shamt == 5'b11000 ? { {24{data[31]}}, data[31:24] } :
    shamt == 5'b11001 ? { {25{data[31]}}, data[31:25] } :
    shamt == 5'b11010 ? { {26{data[31]}}, data[31:26] } :
    shamt == 5'b11011 ? { {27{data[31]}}, data[31:27] } :
    shamt == 5'b11100 ? { {28{data[31]}}, data[31:28] } :
    shamt == 5'b11101 ? { {29{data[31]}}, data[31:29] } :
    shamt == 5'b11110 ? { {30{data[31]}}, data[31:30] } :
    shamt == 5'b11111 ? { {31{data[31]}}, data[31:31] } :
    32'bX;
endmodule

// ALU opcode table:
// ____________________________________
// |         |                        |
// | ALU OP  | Description            |
// |---------|------------------------|
// | 4'b0000 | addition               |
// | 4'b0001 | subtranction           |
// | 4'b0010 | multiplication         |
// |---------|------------------------|
// | 4'b0100 | shift left             |
// | 4'b0110 | shift right unsigned   |
// | 4'b0111 | shift right signed     |
// |---------|------------------------|
// | 4'b1001 | and                    |
// | 4'b1010 | or                     |
// | 4'b1011 | xor                    |
// |---------|------------------------|
// | 4'b1100 | set-less-than unsigned |
// | 4'b1101 | set-less-than signed   |
// |_________|________________________|
//
module Alu(
  input [3:0] alu_op,
  input [31:0] a_data,
  input [31:0] b_data,

  output [31:0] alu_res
);

  wire signed [31:0] signed_a_data = $signed(a_data);
  wire signed [31:0] signed_b_data = $signed(b_data);
  wire [4:0] shamt = b_data[4:0];

  wire [31:0] signed_shifted_data;
  SignedArithShiftWorkaround sasw(
    .data(a_data),
    .shamt(shamt),
    .res(signed_shifted_data)
  ); 

  assign alu_res =
    alu_op == 4'b0000 ? a_data + b_data :
    alu_op == 4'b0001 ? a_data - b_data :
    alu_op == 4'b0010 ? a_data * b_data :

    alu_op == 4'b0100 ? a_data << shamt :
    alu_op == 4'b0110 ? a_data >> shamt :
    alu_op == 4'b0111 ? signed_shifted_data :

    alu_op == 4'b1001 ? a_data & b_data :
    alu_op == 4'b1010 ? a_data | b_data :
    alu_op == 4'b1011 ? a_data ^ b_data :

    alu_op == 4'b1100 ? a_data < b_data ? 1 : 0 :
    alu_op == 4'b1101 ? signed_a_data < signed_b_data ? 1 : 0 :
    {32'bX};

endmodule
