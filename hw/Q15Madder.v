`timescale 1ns/1ps

module Q15Madder (
  input signed [63:0] a,
  input signed [63:0] b,
  input signed [63:0] c,

  output nan,
  output signed [63:0] res
);

  wire mul_nan;
  wire signed [63:0] prod;
  Q15Multiplier mul(
    .a(a_data),
    .b(b_data),
    .nan(mul_nan),
    .res(prod)
  );

  wire signed [63:0] sum;
  wire add_nan;
  Q15Adder add(
    .a(prod),
    .b(c),
    .nan(add_nan),
    .res(sum)
  );

  assign nan = mul_nan | add_nan;
  assign res = sum;

endmodule
