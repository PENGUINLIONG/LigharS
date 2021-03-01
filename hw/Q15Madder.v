`timescale 1ns/1ps

module Q15Madder (
  input signed [63:0] a,
  input signed [63:0] b,
  input signed [63:0] c,

  output signed [63:0] res
);

  wire signed [63:0] prod;
  Q15Multiplier mul(
    .a(a),
    .b(b),
    .res(prod)
  );

  wire signed [63:0] sum;
  wire add_nan;
  Q15Adder add(
    .a(prod),
    .b(c),
    .res(sum)
  );

  assign res = sum;

endmodule
