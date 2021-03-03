`timescale 1ns/1ps

module DataMemory(
  input clk,
  input reset,

  input [31:0] instr_addr,
  input [31:0] data_addr,
  input should_write,
  input [31:0] write_data,

  output [31:0] instr,
  output [31:0] read_data
);

  reg [31:0] inner [1023:0];

  wire word_aligned_instr_addr = { 2'b00, instr_addr[31:2] };
  wire word_aligned_data_addr  = { 2'b00,  data_addr[31:2] };

  assign instr = inner[word_aligned_instr_addr];
  assign read_data = inner[word_aligned_data_addr];

  integer i;
  always @(posedge clk, posedge reset) begin
    if (reset) begin
      for (i = 0; i < 1024; i = i + 1) begin
        inner[i] = 0;
      end
    end
  end

  always @(negedge clk) begin
    if (should_write)
      inner[word_aligned_data_addr] <= write_data;
    else
      inner[word_aligned_data_addr] <= inner[word_aligned_data_addr];
  end

endmodule
