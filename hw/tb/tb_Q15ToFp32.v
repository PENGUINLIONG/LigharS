`timescale 1ns/1ps

`define assert(signal, value) \
  if (signal !== value) begin \
      $display("ASSERTION FAILED in %m: signal != value"); \
      $finish; \
  end

module tb_Q15ToFp32();

  reg [63:0] q15;
  wire [31:0] fp32;

  Q15ToFp32 uut(
    .q15_data(q15),
    .fp32_data(fp32)
  );

  initial begin
    // 0.0
    q15 = 64'h0000000000000000;
    #5; `assert(fp32, 32'b00000000000000000000000000000000);

    // inf
    q15 = 64'h7fffffffffffffff;
    #5; `assert(fp32, 32'b01111111100000000000000000000000);
    // -inf
    q15 = 64'h8000000000000001;
    #5; `assert(fp32, 32'b11111111100000000000000000000000);

    // 32767.9980469 (normalized largest representable number)
    q15 = 64'h7fffff8000000000;
    #5; `assert(fp32, 32'b01000110111111111111111111111111);
    // -32767.9980469 (normalized largest representable number)
    q15 = 64'h8000008000000000;
    #5; `assert(fp32, 32'b11000110111111111111111111111111);

    // 3.5527136788e-15 (normalized smallest representable number)
    q15 = 64'h0000000000000001;
    #5; `assert(fp32, 32'b00100111100000000000000000000000);
    // -3.5527136788e-15 (normalized smallest representable number)
    q15 = 64'hffffffffffffffff;
    #5; `assert(fp32, 32'b10100111100000000000000000000000);

    $display("UNIT TEST PASSED: %m");
  end

endmodule
