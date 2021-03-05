`timescale 1ns/1ps

module Q15Decoder (
  input [63:0] data,

  output sign,
  output nan,
  output zero,
  output inf
);

  assign sign = data[63];
  assign inf = (data == 64'h8000000000000001 ? 1 : 0) | (data == 63'h7fffffffffffffff ? 1 : 0);
  assign zero = data[62:0] == 0 ? 1 : 0;
  assign nan = sign & zero;

endmodule
