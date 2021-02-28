`timescale 1ns/1ps

module Q15Divider (
  input clk,
  input reset,
  input launch,
  input signed [63:0] a,
  input signed [63:0] b,

  output busy,
  output nan,
  output signed [63:0] res
);

  wire signed [68:0] a_extended = {a, 15'b0};
  wire signed [68:0] b_extended = {b, 15'b0};


  wire div_by_zero;
  wire signed [68:0] quotient_extended;
  Divider #(.WIDTH=69) inner(
    .clk(clk),
    .reset(reset),
    .launch(launch),
    .dividend(a_extended),
    .divisor(b_extended),
    .busy(busy),
    .div_by_zero(div_by_zero),
    .quotient(quotient)
  );

  wire signed [63:0] quotient;

  assign nan = div_by_zero;
  assign res = quotient;

endmodule
