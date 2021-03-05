`timescale 1ns/1ps

module Q15Multiplier (
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

  wire signed [126:0] a_extended = {{63{a_sign}}, a};
  wire signed [126:0] b_extended = {{63{b_sign}}, b};
  wire signed [126:0] product_extended = a_extended * b_extended;
  wire signed [63:0]  product = product_extended[111:48];

  wire product_sign  = product[63];
  wire expected_sign = a_sign ^ b_sign;
  wire overflow = a_inf | b_inf | (product_sign != expected_sign ? 1 : 0);

  wire nan = a_nan | b_nan | (a_inf & b_inf);
  assign res =
    nan      ? 64'h8000000000000000 :
    overflow ? (expected_sign ? 64'h7fffffffffffffff : 64'h8000000000000001) :
               product;

endmodule
