`timescale 1ns/1ps

`define assert(signal, value) \
  if (signal !== value) begin \
      $display("ASSERTION FAILED in %m: signal != value"); \
      $finish; \
  end

module tb_Q15Multiplier();

  reg signed [63:0] a, b;
  wire signed [63:0] res;

  Q15Multiplier uut(
    .a(a),
    .b(b),
    .res(res),
    .nan(nan)
  );

  initial begin
  
    // General computation.
    a = 64'h0001200000000000; // 1.125
    b = 64'h0008000000000000; // 8
    #5;
    `assert(res, 64'h0009000000000000);
    `assert(nan, 0);

    a = 64'h0001200000000000; // 1.125
    b = 64'hfff8000000000000; // -8
    #5;
    `assert(res, 64'hfff7000000000000);
    `assert(nan, 0);
    
    // Overflow (Positive infinity as in floating point numbers)
    a = 64'h0002000000000000; // 2
    b = 64'h7fff000000000000; // 65535
    #5;
    `assert(res, 64'h7fffffffffffffff);
    `assert(nan, 0);

    // Overflow (Negative infinity as in floating point numbers)
    a = 64'h0002000000000000; // 2
    b = 64'h8000000000000000; // -65535
    #5;
    `assert(res, 64'hffffffffffffffff);
    `assert(nan, 0);


    $display("UNIT TEST PASSED: %m");
  end

endmodule
