`timescale 1ns/1ps

module X32ToQ15 (
  input sign_mask,
  input [31:0] x32_data,
  output [63:0] q15_data
);

  wire sign = sign_mask & x32_data[31];
  wire signed [31:0] unsigned_x32 = sign ? -x32_data : x32_data;
  wire overflow = unsigned_x32[31:15] != 0 ? 1 : 0;

  assign q15_data =
    overflow ? (sign ? 64'h8000000000000001 : 64'h7fffffffffffffff) :
    (sign ? {-(unsigned_x32[15:0]), 48'b0} : {unsigned_x32[15:0], 48'b0});

endmodule
