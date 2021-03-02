`timescale 1ns/1ps

module Q15ToX32 (
  input [63:0] q15_data,
  output [31:0] i32_data,
  output [31:0] u32_data
);

  wire sign, inf, zero, nan;
  Q15Decoder q15_decode(
    .data(q15_data),
    .sign(sign),
    .inf(inf),
    .zero(zero),
    .nan(nan)
  );

  assign u32_data =
    (nan | sign) ? 0 :
    inf ? 32'h7fffffff :
    {16'b0, q15_data[63:48]};

  assign i32_data =
    nan ? 0 :
    inf ? (sign ? 32'h80000000 : 32'h7fffffff) :
    {{16{sign}}, q15_data[63:48]};

endmodule
