`timescale 1ns/1ps

`define assert(signal, value) \
  if (signal !== value) begin \
      $display("ASSERTION FAILED in %m: signal != value"); \
      $finish; \
  end

module tb_X32ToQ15();

  reg sign_mask;
  reg signed [31:0] x32;
  wire [63:0] q15;

  X32ToQ15 uut(
    .sign_mask(sign_mask),
    .q15_data(q15),
    .x32_data(x32)
  );

  initial begin
    // 1 (unsigned)
    sign_mask = 0; x32 = 1;
    #5; `assert(q15, 64'h0001_000000000000);
    // 1 (signed)
    sign_mask = 1; x32 = 1;
    #5; `assert(q15, 64'h0001_000000000000);

    // -1 (unsigned)
    sign_mask = 0; x32 = -1;
    #5; `assert(q15, 64'h7fff_ffffffffffff);
    // -1 (signed)
    sign_mask = 1; x32 = -1;
    #5; `assert(q15, 64'hffff_000000000000);

    // -inf (unsigned)
    sign_mask = 0; x32 = -32768;
    #5; `assert(q15, 64'h7fff_ffffffffffff);
    // -inf (signed)
    sign_mask = 1; x32 = -32768;
    #5; `assert(q15, 64'h8000_000000000001);

    $display("UNIT TEST PASSED: %m");
  end

endmodule
