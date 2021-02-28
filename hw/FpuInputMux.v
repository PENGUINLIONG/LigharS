`timescale 1ns/1ps

// # Fpu Input Selection Table
// ______________________________________________________________________
// |            |                                                       |
// | FPU Source | Description                                           |
// |------------|-------------------------------------------------------|
// |      2'b00 | General register data (Zero might be introduced here) |
// |      2'b01 | One                                                   |
// |      2'b10 | XMM register data                                     |
// |      2'b11 | Negated XMM register data                             |
// |____________|_______________________________________________________|
module FpuInputMux(
  input [2:0] src,

  input [31:0] rs_data,
  input signed [63:0] xs_data,

  output [63:0] data,
);

  wire [63:0] rs_q15;
  Fp32ToQ15 alu_res_cvt(
    .fp32_data(rs_data),
    .q15_data(rs_q15)
  );

  wire data =
    src == 2'b00 ? rs_q15 :
    src == 2'b01 ? 0'h8001000000000000 :
    src == 2'b10 ? xs_data :
    src == 2'b11 ? -xs_data :
    32'bX;

endmodule
