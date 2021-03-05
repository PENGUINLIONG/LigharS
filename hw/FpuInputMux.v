`timescale 1ns/1ps

// # Fpu Input Selection Table
// ______________________________________________________________________
// |            |                                                       |
// | FPU Source | Description                                           |
// |------------|-------------------------------------------------------|
// |     3'b000 | Zero                                                  |
// |     3'b001 | One                                                   |
// |     3'b010 | XMM register data                                     |
// |     3'b011 | General register data (converted from fp32)           |
// |     3'b100 | General register data (converted from u32)            |
// |     3'b101 | General register data (converted from i32)            |
// |____________|_______________________________________________________|
module FpuInputMux(
  input [2:0] src,

  input [31:0] rs_data,
  input signed [63:0] xs_data,

  output [63:0] data
);

  wire [63:0] rs_float_q15;
  Fp32ToQ15 rs_float_cvt(
    .fp32_data(rs_data),
    .q15_data(rs_float_q15)
  );

  wire [63:0] rs_int_q15;
  X32ToQ15 rs_int_cvt(
    .sign_mask(src[0]),
    .x32_data(rs_data),
    .q15_data(rs_int_q15)
  );

  assign data =
    src == 3'b000 ? 0 :
    src == 3'b001 ? 64'h0001000000000000 :
    src == 3'b010 ? xs_data :
    src == 3'b011 ? rs_float_q15 :
    src == 3'b100 ? rs_int_q15 :
    src == 3'b101 ? rs_int_q15 :
    32'bX;

endmodule
