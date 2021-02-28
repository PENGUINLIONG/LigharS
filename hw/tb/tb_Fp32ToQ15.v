`timescale 1ns/1ps

`define assert(signal, value) \
  if (signal !== value) begin \
      $display("ASSERTION FAILED in %m: signal != value"); \
      $finish; \
  end

module tb_Fp32ToQ15();

  reg [31:0] fp32;
  wire [63:0] q15;

  Fp32ToQ15 uut(
    .fp32_data(fp32),
    .q15_data(q15)
  );

  initial begin
    // 0.0
    fp32 = 32'b00000000000000000000000000000000;
    #5; `assert(q15, 64'h0000000000000000);
    // -0.0
    fp32 = 32'b10000000000000000000000000000000;
    #5; `assert(q15, 64'h0000000000000000);

    // 32768 (overflow to inf)
    fp32 = 32'b01000111000000000000000000000000;
    #5; `assert(q15, 64'h7fffffffffffffff);
    // -32768 (overflow to -inf)
    fp32 = 32'b11000111000000000000000000000000;
    #5; `assert(q15, 64'h8000000000000001);

    // inf
    fp32 = 32'b01111111100000000000000000000000;
    #5; `assert(q15, 64'h7fffffffffffffff);
    // -inf
    fp32 = 32'b11111111100000000000000000000000;
    #5; `assert(q15, 64'h8000000000000001);

    // 32767.9980469 (normalized largest representable number, truncated)
    fp32 = 32'b01000110111111111111111111111111;
    #5; `assert(q15, 64'h7fffff8000000000);
    // -32767.9980469 (normalized largest representable number, truncated)
    fp32 = 32'b11000110111111111111111111111111;
    #5; `assert(q15, 64'h8000008000000000);

    // 3.5527136788e-15 (normalized smallest representable number, truncated)
    fp32 = 32'b00100111100000000000000000000000;
    #5; `assert(q15, 64'h0000000000000001);
    // -3.5527136788e-15 (normalized smallest representable number, truncatedf)
    fp32 = 32'b10100111100000000000000000000000;
    #5; `assert(q15, 64'hffffffffffffffff);

    $display("UNIT TEST PASSED: %m");
  end

endmodule
