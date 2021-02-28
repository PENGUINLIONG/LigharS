`timescale 1ns/1ps

module RegisterWriteMux(
  input [1:0] src,
  input [31:0] alu_res,
  input [31:0] mem_read_data,

  output [31:0] reg_write_data
);

  assign reg_write_data = 
    src == 2'b01 ? alu_res :
    src == 2'b10 ? mem_read_data :
    32'bX;

endmodule
