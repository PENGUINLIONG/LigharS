`timescale 1ns/1ps

module Q15Adder (
  input signed [63:0] a,
  input signed [63:0] b,

  output signed [63:0] res
);

  wire a_sign, a_nan, a_zero, a_inf;
  Q15Decoder decode_a(
    .data(a),
    .sign(a_sign),
    .nan (a_nan),
    .zero(a_zero),
    .inf (a_inf)
  );
  wire b_sign, b_nan, b_zero, b_inf;
  Q15Decoder decode_b(
    .data(b),
    .sign(b_sign),
    .nan (b_nan),
    .zero(b_zero),
    .inf (b_inf)
  );

  wire nan = a_nan | b_nan | (a_inf & b_inf);

  wire signed [64:0] a_extended = {a_sign, a};
  wire signed [64:0] b_extended = {b_sign, b};
  wire signed [64:0] sum_extended = a_extended + b_extended;
  wire signed [63:0] sum = sum_extended[63:0];
  
  // Two arguments have the same sign, but the result has a different sign.
  wire sum_sign = sum[63];
  wire a_b_same_sign   = a_sign ==   b_sign ? 1 : 0;
  wire a_sum_diff_sign = a_sign != sum_sign ? 1 : 0;
  wire overflow = a_inf | b_inf | (a_b_same_sign & a_sum_diff_sign);

  assign res =
    nan      ? 64'h8000000000000000 :
    overflow ? (sum_sign ? 64'h7fffffffffffffff : 64'h8000000000000001) :
               sum;

endmodule
