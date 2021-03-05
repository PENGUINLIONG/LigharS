`timescale 1ns/1ps
// Register file specialized for fixed-point arithmetics. `XmmRegisterFile`
// stores signed q15.48 fixed-point numbers which are 64 bits in width.

module XmmRegisterFile(
  input clk,
  input reset,

  input [4:0] read_addr1,
  input [4:0] read_addr2,
  input should_write,
  input [4:0] write_addr,
  input [63:0] write_data,

  output [63:0] read_data1,
  output [63:0] read_data2
);

  reg [63:0] inner [31:0];

  assign read_data1 = inner[read_addr1];
  assign read_data2 = inner[read_addr2];

  integer i;
  always @(posedge clk, posedge reset) begin
    if (reset) begin
      for (i = 0; i < 32; i = i + 1) begin
        inner[i] = 0;
      end
    end
  end

  always @(negedge clk) begin
    if (should_write)
      inner[write_addr] <= write_data;
    else
      inner[write_addr] <= inner[write_addr];
  end

endmodule


