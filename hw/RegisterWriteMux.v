`timescale 1ns/1ps

module RegisterWriteMux(
  input [1:0] src,
  input [31:0] alu_res,
  input [31:0] mem_read_data,
  input [63:0] fpu_res,

  output [31:0] reg_write_data
);

  wire [31:0] fpu_res_fp32;
  Fp32ToQ15 fpu_res_cvt(
    .q15_data(fpu_res),
    .fp32_data(fpu_res_fp32)
  );

  assign reg_write_data = 
    src == 2'b01 ? alu_res :
    src == 2'b10 ? mem_read_data :
    src == 2'b11 ? fpu_res_fp32 :
    32'bX;

endmodule
