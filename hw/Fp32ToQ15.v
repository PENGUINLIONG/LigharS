`timescale 1ns/1ps

module Fp32ToQ15 (
  input [31:0] fp32_data,
  output [63:0] q15_data
);

  wire sign;
  wire [7:0] exponent;
  wire [22:0] mantissa;
  wire zero, denorm, inf, nan;
  Fp32Decoder decoder(
    .data(fp32_data),
    .sign(sign),
    .exponent(exponent),
    .mantissa(mantissa),
    .is_zero(zero),
    .is_denorm(denorm),
    .is_inf(inf),
    .is_nan(nan)
  );

  wire inf_override  = inf  | (exponent >= 142 ? 1 : 0);
  wire zero_override = zero | (exponent < 78 ? 1 : 0);
  wire [6:0] shamt = 8'd142 - exponent;

  // Note that denormalized floating-point numbers cannot be represented in q15.
  wire signed [63:0] shifted = {2'b1, mantissa, 40'b0} >> shamt;
  wire [63:0] signed_shifted = sign ? -shifted : shifted;

  wire [63:0] mantissa_extended = {sign, 15'b0, mantissa, 25'b0};

  assign q15_data =
    nan           ? 64'h8000000000000000 :
    inf_override  ? (sign ? 64'h8000000000000001 : 64'h7fffffffffffffff) :
    zero_override ? 0 :
                    signed_shifted;

endmodule
