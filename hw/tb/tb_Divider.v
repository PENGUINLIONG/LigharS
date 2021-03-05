`timescale 1ns / 1ps

`define assert(signal, value) \
  if (signal !== value) begin \
      $display("ASSERTION FAILED in %m: signal != value"); \
      $finish; \
  end

module tb_Divider ();
  reg clk;
  reg reset;
  reg launch;
  reg [3:0] dividend;
  reg [3:0] divisor;

  wire busy;
  wire div_by_zero;
  wire [3:0] quotient;
  wire [3:0] remainder;
  
  Divider uut(
    .clk(clk),
    .reset(reset),
    .launch(launch),
    .dividend(dividend),
    .divisor(divisor),
    .busy(busy),
    .div_by_zero(div_by_zero),
    .quotient(quotient),
    .remainder(remainder)
  );

  initial begin
    clk = 0;
    reset = 1;
    launch = 0;
    dividend = 7;
    divisor = 3;
    #5 clk = ~clk;
    #5 clk = ~clk;
    reset = 0;
    #5;
    `assert(busy, 0);
    #5;

    // Test for normal division.
    launch = 1;
    #5 clk = ~clk; #5 clk = ~clk;
    launch = 0;
    `assert(busy, 1);
    `assert(div_by_zero, 0);
    #5 clk = ~clk; #5 clk = ~clk;
    #5 clk = ~clk; #5 clk = ~clk;
    #5 clk = ~clk; #5 clk = ~clk;
    #5 clk = ~clk; #5 clk = ~clk;
    #5 clk = ~clk; #5 clk = ~clk;
    #5 clk = ~clk; #5 clk = ~clk;
    #5 clk = ~clk; #5 clk = ~clk;
    `assert(busy, 0);
    `assert(div_by_zero, 0);
    `assert(quotient, 2);
    `assert(remainder, 2);

    // Divide by zero.
    #5 clk = ~clk; #5 clk = ~clk;
    launch = 1;
    divisor = 0;
    #5 clk = ~clk; #5 clk = ~clk;
    `assert(busy, 0);
    `assert(div_by_zero, 1);

    $display("UNIT TEST PASSED: %m");
  end

endmodule
