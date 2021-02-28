`timescale 1ns/1ps
// Decode and classify 32-bit floating-point number representation.

module Fp32Decoder (
  input [31:0] data,

  output sign,
  output [7:0] exponent,
  output [22:0] mantissa,

  output is_zero,
  output is_denorm,
  output is_inf,
  output is_nan
);

  assign sign     = data[31];
  assign exponent = data[30:23];
  assign mantissa = data[22:0];

  wire exponent_all_clr = exponent ==   0 ? 1 : 0;
  wire exponent_all_set = exponent == 255 ? 1 : 0;
  wire mantissa_all_clr = mantissa ==   0 ? 1 : 0;

  assign is_zero   =  exponent_all_clr &  mantissa_all_clr;
  assign is_denorm =  exponent_all_clr & !mantissa_all_clr;
  assign is_inf    =  exponent_all_set &  mantissa_all_clr;
  assign is_nan    =  exponent_all_set & !mantissa_all_clr;

endmodule
