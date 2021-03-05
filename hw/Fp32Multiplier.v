`timescale 1ns/1ps

// A * B + C
module Fp32Multiplier (
  input        sign_a,
  input [7:0]  exponent_a,
  input [22:0] mantissa_a,
  input        is_denorm_a,
  input        sign_b,
  input [7:0]  exponent_b,
  input [22:0] mantissa_b,
  input        is_denorm_b,

  output        sign_res,
  output [7:0]  exponent_res,
  output [22:0] mantissa_res
);

  wire [8:0] exponent_a_extended = {1'b0, exponent_a};
  wire [8:0] exponent_b_extended = {1'b0, exponent_b};
  wire [8:0] exponent_sum_extended = exponent_a_extended + exponent_b_extended;
  wire [7:0] exponent_sum  = exponent_sum_extended[7:0];
  wire       overflow      = exponent_sum_extended[8];
  wire       underflow     = exponent_sum <= 127;
  wire [7:0] normalized_exponent_res =
    underflow ?  8'b0 :
    overflow  ? ~8'b0 :
    mantissa_prod[43] ? exponent_sum - 00 :
    mantissa_prod[43] ? exponent_sum - 01 :
    mantissa_prod[42] ? exponent_sum - 02 :
    mantissa_prod[41] ? exponent_sum - 03 :
    mantissa_prod[40] ? exponent_sum - 04 :
    mantissa_prod[39] ? exponent_sum - 05 :
    mantissa_prod[38] ? exponent_sum - 06 :
    mantissa_prod[37] ? exponent_sum - 07 :
    mantissa_prod[36] ? exponent_sum - 08 :
    mantissa_prod[35] ? exponent_sum - 09 :
    mantissa_prod[34] ? exponent_sum - 10 :
    mantissa_prod[33] ? exponent_sum - 11 :
    mantissa_prod[32] ? exponent_sum - 12 :
    mantissa_prod[31] ? exponent_sum - 13 :
    mantissa_prod[30] ? exponent_sum - 14 :
    mantissa_prod[29] ? exponent_sum - 15 :
    mantissa_prod[28] ? exponent_sum - 16 :
    mantissa_prod[27] ? exponent_sum - 17 :
    mantissa_prod[26] ? exponent_sum - 18 :
    mantissa_prod[25] ? exponent_sum - 19 :
    mantissa_prod[24] ? exponent_sum - 20 :
    mantissa_prod[23] ? exponent_sum - 21 :
                        exponent_sum - 22;

  wire [44:0] mantissa_a_extended = {23'b0, ~is_denorm_a, mantissa_a};
  wire [44:0] mantissa_b_extended = {23'b0, ~is_denorm_b, mantissa_b};
  wire [44:0] mantissa_prod_extended = mantissa_a_extended * mantissa_b_extended;
  wire [22:0] normalized_mantissa_prod =
    mantissa_prod[44] ? mantissa_prod_extended[44:22] :
    mantissa_prod[43] ? mantissa_prod_extended[43:21] :
    mantissa_prod[42] ? mantissa_prod_extended[42:20] :
    mantissa_prod[41] ? mantissa_prod_extended[41:19] :
    mantissa_prod[40] ? mantissa_prod_extended[40:18] :
    mantissa_prod[39] ? mantissa_prod_extended[39:17] :
    mantissa_prod[38] ? mantissa_prod_extended[38:16] :
    mantissa_prod[37] ? mantissa_prod_extended[37:15] :
    mantissa_prod[36] ? mantissa_prod_extended[36:14] :
    mantissa_prod[35] ? mantissa_prod_extended[35:13] :
    mantissa_prod[34] ? mantissa_prod_extended[34:12] :
    mantissa_prod[33] ? mantissa_prod_extended[33:11] :
    mantissa_prod[32] ? mantissa_prod_extended[32:10] :
    mantissa_prod[31] ? mantissa_prod_extended[31:09] :
    mantissa_prod[30] ? mantissa_prod_extended[30:08] :
    mantissa_prod[29] ? mantissa_prod_extended[29:07] :
    mantissa_prod[28] ? mantissa_prod_extended[28:06] :
    mantissa_prod[27] ? mantissa_prod_extended[27:05] :
    mantissa_prod[26] ? mantissa_prod_extended[26:04] :
    mantissa_prod[25] ? mantissa_prod_extended[25:03] :
    mantissa_prod[24] ? mantissa_prod_extended[24:02] :
    mantissa_prod[23] ? mantissa_prod_extended[23:01] :
                        mantissa_prod_extended[22:00];

  assign sign_res = sign_a ^ sign_b;
  assign exponent_res = normalized_exponent_res;
  assign mantissa_res = normalized_mantissa_prod;

  
endmodule
