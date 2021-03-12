`timescale 1ns/1ps
// This is not a Floating-point Processing Unit but a Fixed-point Processing
// Unit. This is expected to achieve better precision then floating point
// arithmetics while retaining better performance.

// FPU opcode table:
// _________________________________________
// |         |                             |
// | FPU OP  | Description                 |
// |---------|-----------------------------|
// | 4'b0000 | A + B                       |
// | 4'b0001 | A - B                       |
// | 4'b0010 | A * B                       |
// | 4'b0011 | A / B                       |
// |---------|-----------------------------|
// | 4'b0100 |  sign(B)           * abs(A) |
// | 4'b0101 | -sign(B)           * abs(A) |
// | 4'b0110 |  sign(B) ^ sign(A) * abs(A) |
// |---------|-----------------------------|
// | 4'b1000 | A <= B ? 1 : 0              |
// | 4'b1001 | A <  B ? 1 : 0              |
// | 4'b1010 | A == B ? 1 : 0              |
// |---------|-----------------------------|
// | 4'b1100 | A < B ? A : B (min)         |
// | 4'b1101 | A < B ? B : A (max)         |
// |_________|_____________________________|
//
module Fpu (
  input clk,
  input reset,

  input [3:0] fpu_op,
  input signed [63:0] a_data,
  input signed [63:0] b_data,

  output busy,
  output signed [63:0] fpu_res
);

  wire signed [63:0] prod;
  Q15Multiplier mul(
    .a(a_data),
    .b(b_data),
    .res(prod)
  );

  wire signed [63:0] sum;
  Q15Adder add(
    .a(a_data),
    .b(b_data),
    .res(sum)
  );

  wire signed [63:0] diff;
  Q15Adder sub(
    .a(a_data),
    .b(-b_data),
    .res(diff)
  );

  wire div_busy;
  wire launch_div = (fpu_op == 4'b0011 ? 1 : 0) & !div_busy;
  wire signed [63:0] quot;
  Q15Divider div(
    .clk(clk),
    .reset(reset),
    .launch(launch_div),
    .a(a_data),
    .b(b_data),
    .busy(div_busy),
    .res(quot)
  );

  wire a_sign = a_data[63];
  wire b_sign = b_data[63];
  wire [63:0] unsigned_a_data = a_sign ? -a_data : a_data;

  assign busy = div_busy;
  assign fpu_res =
    fpu_op == 4'b0000 ? sum :
    fpu_op == 4'b0001 ? diff :
    fpu_op == 4'b0010 ? prod :
    fpu_op == 4'b0011 ? quot :
    fpu_op == 4'b0100 ? (b_sign          ? -unsigned_a_data : unsigned_a_data) :
    fpu_op == 4'b0101 ? (b_sign          ? -unsigned_a_data : unsigned_a_data) :
    fpu_op == 4'b0110 ? (b_sign ^ a_sign ? -unsigned_a_data : unsigned_a_data) :
    fpu_op == 4'b1000 ? (a_data <= b_data ? 1 : 0) :
    fpu_op == 4'b1001 ? (a_data <  b_data ? 1 : 0) :
    fpu_op == 4'b1010 ? (a_data == b_data ? 1 : 0) :
    fpu_op == 4'b1100 ? (a_data < b_data ? a_data : b_data) :
    fpu_op == 4'b1101 ? (a_data < b_data ? b_data : a_data) :
    64'bX;

endmodule
