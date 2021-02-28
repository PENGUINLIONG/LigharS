`timescale 1ns/1ps

module XmmRegisterWriteMux(
  input [1:0] src,
  input [31:0] alu_res,
  input [31:0] mem_read_data,
  input [63:0] fpu_res,

  output [31:0] xmm_write_data
);

  wire [63:0] alu_res_q15;
  Fp32ToQ15 alu_res_cvt(
    .fp32_data(alu_res),
    .q15_data(alu_res_q15)
  );

  wire [63:0] mem_read_data_q15;
  Fp32ToQ15 mem_read_data_cvt(
    .fp32_data(alu_res),
    .q15_data(mem_read_data_q15)
  );

  assign xmm_write_data =
    src == 2'b01 ? alu_res_q15 :
    src == 2'b10 ? mem_read_data_q15 :
    src == 2'b11 ? fpu_res :
                   32'bX;

endmodule
