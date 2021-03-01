`timescale 1ns/1ps
// This is not a Floating-point Processing Unit but a Fixed-point Processing
// Unit. This is expected to achieve better precision then floating point
// arithmetics while retaining better performance.

// FPU opcode table:
// ____________________________________
// |         |                        |
// | FPU OP  | Description            |
// |---------|------------------------|
// |  3'b000 |   A * B + C            |
// |  3'b001 |   A * B - C            |
// |  3'b010 | - A * B + C            |
// |  3'b011 | - A * B - C            |
// |---------|------------------------|
// |  3'b100 |   A / B                |
// |_________|________________________|
//
module Fpu (
  input clk,
  input reset,

  input [2:0] fpu_op,
  input signed [63:0] a_data,
  input signed [63:0] b_data,
  input signed [63:0] c_data,

  output busy,
  output signed [63:0] fpu_res
);

  wire mul_div = fpu_op[2];
  wire neg_a   = fpu_op[1];
  wire neg_c   = fpu_op[0];

  wire signed [63:0] a = neg_a ? -a_data : a_data;
  wire signed [63:0] b = b_data;
  wire signed [63:0] c = neg_c ? -c_data : c_data;

  assign busy = div_busy;

  wire signed [63:0] mad_res;
  Q15Madder mad(
    .a(a),
    .b(b),
    .c(c),
    .res(mad_res)
  );

  wire launch_div = mul_div & !div_busy;
  wire div_busy;
  wire signed [63:0] div_res;
  Q15Divider div(
    .clk(clk),
    .reset(reset),
    .launch(launch_div),
    .a(a),
    .b(b),
    .busy(div_busy),
    .res(div_res)
  );

  assign fpu_res = mul_div ? div_res : mad_res;

endmodule
