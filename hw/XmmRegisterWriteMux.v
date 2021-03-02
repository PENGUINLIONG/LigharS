`timescale 1ns/1ps

// # XMM Register Write Data Selection Table
// ________________________________________________________________________
// |              |                                                       |
// | Write Source | Description                                           |
// |--------------|-------------------------------------------------------|
// |       3'b000 | ALU result (converted from u32)                       |
// |       3'b001 | ALU result (converted from i32)                       |
// |       3'b010 | ALU result (converted from fp32)                      |
// |       3'b100 | Memory access result                                  |
// |       3'b110 | FPU result                                            |
// |______________|_______________________________________________________|
module XmmRegisterWriteMux(
  input [1:0] src,
  input [31:0] alu_res,
  input [31:0] mem_read_data,
  input [63:0] fpu_res,

  output [63:0] xmm_write_data
);

  wire [63:0] alu_res_float_q15;
  Fp32ToQ15 alu_res_float_cvt(
    .fp32_data(alu_res),
    .q15_data(alu_res_float_q15)
  );

  wire [63:0] mem_read_data_q15;
  Fp32ToQ15 mem_read_data_cvt(
    .fp32_data(alu_res),
    .q15_data(mem_read_data_q15)
  );

  wire [63:0] alu_res_int_q15;
  X32ToQ15 alu_res_int_cvt(
    .sign_mask(src[0]),
    .x32_data(alu_res),
    .q15_data(alu_res_int_q15)
  );

  assign xmm_write_data =
    src[2:1] == 2'b00 ? alu_res_int_q15 :
    src[2:1] == 2'b01 ? alu_res_float_q15 :
    src[2:1] == 2'b10 ? mem_read_data_q15 :
    src[2:1] == 2'b11 ? fpu_res :
    32'bX;

endmodule
