`timescale 1ns/1ps

`define assert(signal, value) \
  if (signal !== value) begin \
      $display("ASSERTION FAILED in %m: signal != value"); \
      $finish; \
  end

module tb_Q15Divider();

  reg clk, reset, launch;

  reg signed [63:0] a, b;
  wire busy;
  wire signed [63:0] res;

  Q15Divider uut(
    .clk(clk),
    .reset(reset),
    .launch(launch),
    .a(a),
    .b(b),
    .busy(busy),
    .res(res)
  );

  initial begin
    clk = 0;
    reset = 1;
    #10;
    reset = 0;

    // General computation.
    a = 64'h0009000000000000; // 9
    b = 64'h0008000000000000; // 8
    launch = 1; #5 clk = ~clk; #5 clk = ~clk; while (busy) begin #5 clk = ~clk; #5 clk = ~clk; launch = 0; end
    `assert(res, 64'h0001200000000000); // 1.125

    a = 64'h0009000000000000; // 9
    b = 64'hfff8000000000000; // -8
    launch = 1; #5 clk = ~clk; #5 clk = ~clk; while (busy) begin #5 clk = ~clk; #5 clk = ~clk; launch = 0; end
    `assert(res, 64'hfffee00000000000); // -1.125

    // Underflow
    a = 64'h0000000000000001; // 1*2^-48
    b = 64'h0002000000000000; // 2
    launch = 1; #5 clk = ~clk; #5 clk = ~clk; while (busy) begin #5 clk = ~clk; #5 clk = ~clk; launch = 0; end
    `assert(res, 64'h0000000000000000); // 0

    // Negative infinity nop.
    a = 64'h8000000000000001; // -Inf
    b = 64'h0002000000000000; // 2
    launch = 1; #5 clk = ~clk; #5 clk = ~clk; while (busy) begin #5 clk = ~clk; #5 clk = ~clk; launch = 0; end
    `assert(res, 64'h8000000000000001); // -Inf

    // NaN
    a = 64'h7fffffffffffffff; // Inf
    b = 64'h8000000000000001; // -Inf
    launch = 1; #5 clk = ~clk; #5 clk = ~clk; while (busy) begin #5 clk = ~clk; #5 clk = ~clk; launch = 0; end
    `assert(res, 64'h8000000000000000);

    $display("UNIT TEST PASSED: %m");
  end

endmodule
