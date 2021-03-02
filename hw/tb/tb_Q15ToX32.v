`timescale 1ns/1ps

`define assert(signal, value) \
  if (signal !== value) begin \
      $display("ASSERTION FAILED in %m: signal != value"); \
      $finish; \
  end

module tb_Q15ToX32();

  reg [63:0] q15;
  wire [31:0] i32;
  wire [31:0] u32;

  Q15ToX32 uut(
    .q15_data(q15),
    .i32_data(i32),
    .u32_data(u32)
  );

  initial begin
    // 1
    q15 = 64'h0001_000000000000;
    #5; `assert(i32, 1);
    #5; `assert(u32, 1);
    // -1
    q15 = 64'hffff_000000000000;
    #5; `assert(i32, 32'hffffffff);
    #5; `assert(u32, 0);

    // inf
    q15 = 64'h7fffffffffffffff;
    #5; `assert(i32, 32'h7fffffff);
    #5; `assert(u32, 32'h7fffffff);
    // -inf
    q15 = 64'h8000000000000001;
    #5; `assert(i32, 32'h80000000);
    #5; `assert(u32, 0);

    $display("UNIT TEST PASSED: %m");
  end

endmodule
