`timescale 1ns/1ps

// # Memory Write Data Selection Table
// ________________________________________________________________________
// |              |                                                       |
// | Write Source | Description                                           |
// |--------------|-------------------------------------------------------|
// |        2'b01 | General register data                                 |
// |        2'b10 | XMM register data (converted to fp32)                 |
// |______________|_______________________________________________________|
module MemoryWriteMux(
  input [1:0] src,
  input [31:0] rs2_data,
  input [63:0] xs2_data,

  output [31:0] mem_write_data
);

  wire [31:0] xs2_fp32;
  Q15ToFp32 xs2_cvt(
    .q15_data(xs2_data),
    .fp32_data(xs2_fp32)
  );

  assign mem_write_data =
    src == 2'b01 ? rs2_data :
    src == 2'b10 ? xs2_fp32 :
    32'bX;

endmodule
