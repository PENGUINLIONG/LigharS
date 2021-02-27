`timescale 1ns/1ps

module Q15Divider (
  input clk,
  input reset,
  input launch,
  input op, // 0 for division, 1 for modulo.
  input signed [63:0] a,
  input signed [63:0] b,

  output busy,
  output div_by_zero,
  output signed [63:0] res
);

  wire signed [68:0] a_extended = {a, 15'b0};
  wire signed [68:0] b_extended = {b, 15'b0};


  wire signed [68:0] quotient_extended;
  wire signed [68:0] remainder_extended;
  Divider #(.WIDTH=69) inner(
    .clk(clk),
    .reset(reset),
    .launch(launch),
    .dividend(a_extended),
    .divisor(b_extended),
    .busy(busy),
    .div_by_zero(div_by_zero),
    .quotient(quotient),
    .remainder(remainder)
  );

  wire signed [63:0] quotient;
  wire signed [63:0] remainder;

  assign res = op ? remainder : quotient;

endmodule
