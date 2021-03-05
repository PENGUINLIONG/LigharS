`timescale 1ns/1ps

`define assert(signal, value) \
  if (signal !== value) begin \
      $display("ASSERTION FAILED in %m: signal != value"); \
      $finish; \
  end

`define test_write(xwrite_en, xdst_addr, xdst_data) \
  write_en = xwrite_en; \
  dst_addr = xdst_addr; \
  dst_data = xdst_data; \
  #5 clk = ~clk; #5 clk = ~clk;
`define test_read(xsrc_addr1, xsrc_addr2, zsrc_data1, zsrc_data2) \
  write_en = 0; \
  src_addr1 = xsrc_addr1; \
  src_addr2 = xsrc_addr2; \
  #5 clk = ~clk; #5 clk = ~clk; \
  `assert(src_data1, zsrc_data1); \
  `assert(src_data2, zsrc_data2);
`define test_read_write(xwrite_en, xdst_addr, xdst_data, xsrc_addr1, xsrc_addr2, zsrc_data1, zsrc_data2) \
  write_en = xwrite_en; \
  dst_addr = xdst_addr; \
  dst_data = xdst_data; \
  src_addr1 = xsrc_addr1; \
  src_addr2 = xsrc_addr2; \
  #5 clk = ~clk; \
  `assert(src_data1, zsrc_data1); \
  `assert(src_data2, zsrc_data2); \
  #5 clk = ~clk;

module tb_RegisterFile;
  reg clk, reset;

  reg write_en;
  reg [4:0] dst_addr;
  reg [31:0] dst_data;

  reg [4:0] src_addr1;
  reg [4:0] src_addr2;
  wire [31:0] src_data1;
  wire [31:0] src_data2;

  RegisterFile uut(
    .clk(clk),
    .reset(reset),
    .should_write(write_en),
    .write_addr(dst_addr),
    .write_data(dst_data),
    .read_addr1(src_addr1),
    .read_addr2(src_addr2),
    .read_data1(src_data1),
    .read_data2(src_data2)
  );

  initial begin
    clk = 1;
    reset = 1;
    #5 clk = ~clk; #5 clk = ~clk;
    #5 clk = ~clk; #5 clk = ~clk;
    reset = 0;
    

    // Values are only written when `write_en` is on, and writes to zero
    // register is always ignored.
    `test_write(0, 1, ~0);
    `test_write(1, 0, ~0);
    `test_read(0, 1, 0, 0);

    // Reads and write are collected.
    `test_write(1, 1, 1);
    `test_write(1, 2, 2);
    `test_read(1, 2, 1, 2);

    // Read data are collected first, so the write at the same clock will not
    // overwrite existing results.
    `test_read_write(1, 1, 3, 1, 2, 1, 2);
    `test_read(1, 2, 3, 2);

    // Make sure reset works.
    reset = 1;
    #10;
    `test_read(1, 2, 0, 0);

    $display("UNIT TEST PASSED: %m");
  end


endmodule