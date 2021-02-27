`timescale 1ns/1ps

module Q15Multiplier (
  input signed [63:0] a,
  input signed [63:0] b,

  output overflow,
  output signed [63:0] res
);

  wire signed [126:0] a_extended = {{63{a[63]}}, a};
  wire signed [126:0] b_extended = {{63{b[63]}}, b};
  wire signed [126:0] product_extended = a_extended * b_extended;
  wire signed [63:0]  product = product_extended[111:48];

  wire sign_res = a[63] ^ b[63];
  assign overflow = product_extended[111] != sign_res ? 1 : 0;
  assign res = overflow ? {sign_res, ~63'h0} : product;

endmodule
