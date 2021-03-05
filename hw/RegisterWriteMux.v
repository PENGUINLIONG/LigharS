`timescale 1ns/1ps

// # Register Write Data Selection Table
// ________________________________________________________________________
// |              |                                                       |
// | Write Source | Description                                           |
// |--------------|-------------------------------------------------------|
// |       3'b000 | FPU result (converted to u32)                         |
// |       3'b001 | FPU result (converted to i32)                         |
// |       3'b010 | ALU result                                            |
// |       3'b100 | Memory access result                                  |
// |       3'b110 | FPU result (converted to fp32)                        |
// |______________|_______________________________________________________|
module RegisterWriteMux(
  input [2:0] src,
  input [31:0] alu_res,
  input [31:0] mem_read_data,
  input [63:0] fpu_res,

  output [31:0] reg_write_data
);

  wire [31:0] fpu_res_fp32;
  Q15ToFp32 fpu_res_float_cvt(
    .q15_data(fpu_res),
    .fp32_data(fpu_res_fp32)
  );

  wire [31:0] fpu_res_i32;
  wire [31:0] fpu_res_u32;
  Q15ToX32 fpu_res_int_cvt(
    .q15_data(fpu_res),
    .i32_data(fpu_res_i32),
    .u32_data(fpu_res_u32)
  );

  assign reg_write_data =
    src == 3'b000 ? fpu_res_i32 :
    src == 3'b001 ? fpu_res_u32 :
    src == 3'b010 ? alu_res :
    src == 3'b100 ? mem_read_data :
    src == 3'b110 ? fpu_res_fp32 :
    32'bX;

endmodule
