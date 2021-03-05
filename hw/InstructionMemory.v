`timescale 1ns/1ps

module InstructionMemory(
  input [31:0] addr,

  output [31:0] instr
);

  reg [31:0] inner [255:0];

  assign instr = inner[{2'b0, addr[31:2] }];

endmodule
