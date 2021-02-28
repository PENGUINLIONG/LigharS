`timescale 1ns/1ps

module Q15Adder (
  input signed [63:0] a,
  input signed [63:0] b,

  output nan,
  output signed [63:0] res
);

  wire signed [64:0] a_extended = {a[63], a};
  wire signed [64:0] b_extended = {b[63], b};
  wire signed [64:0] sum_extended = a_extended + b_extended;
  wire signed [63:0] sum = sum_extended[63:0];

  // Two arguments have the same sign, but the result has a different sign.
  wire overflow = (a[63] ^~ b[63]) & (a[63] ^ sum[63]);
  assign res = overflow ? {a[63], ~63'h0} : sum;

endmodule
