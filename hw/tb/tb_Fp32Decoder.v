`timescale 1ns / 1ps

`define assert(signal, value) \
  if (signal !== value) begin \
      $display("ASSERTION FAILED in %m: signal != value"); \
      $finish; \
  end

module tb_Fp32Decoder ();

  reg [31:0] data;
  wire sign;
  wire [7:0] exponent;
  wire [22:0] mantissa;
  wire is_zero, is_denorm, is_inf, is_nan;

  Fp32Decoder uut(
    .data(data),
    .sign(sign),
    .exponent(exponent),
    .mantissa(mantissa),
    .is_zero(is_zero),
    .is_denorm(is_denorm),
    .is_inf(is_inf),
    .is_nan(is_nan)
  );

  initial begin
    // Positive zero.
    data = 32'h00000000;
    #5;
    `assert(sign,      0);
    `assert(exponent,  0);
    `assert(mantissa,  0);
    `assert(is_zero,   1);
    `assert(is_denorm, 0);
    `assert(is_inf,    0);
    `assert(is_nan,    0);

    // Smallest representable positive fp32 denormalized value.
    data = 32'h00000001;
    #5;
    `assert(sign,      0);
    `assert(exponent,  0);
    `assert(mantissa,  1);
    `assert(is_zero,   0);
    `assert(is_denorm, 1);
    `assert(is_inf,    0);
    `assert(is_nan,    0);

    // Smallest representable positive fp32 normalized value.
    data = 32'h00800000;
    #5;
    `assert(sign,      0);
    `assert(exponent,  1);
    `assert(mantissa,  0);
    `assert(is_zero,   0);
    `assert(is_denorm, 0);
    `assert(is_inf,    0);
    `assert(is_nan,    0);

    // Positive infinity.
    data = 32'h7f800000;
    #5;
    `assert(sign,      0);
    `assert(exponent,  255);
    `assert(mantissa,  0);
    `assert(is_zero,   0);
    `assert(is_denorm, 0);
    `assert(is_inf,    1);
    `assert(is_nan,    0);

    // Positive zero.
    data = 32'h80000000;
    #5;
    `assert(sign,      1);
    `assert(exponent,  0);
    `assert(mantissa,  0);
    `assert(is_zero,   1);
    `assert(is_denorm, 0);
    `assert(is_inf,    0);
    `assert(is_nan,    0);

    // Smallest representable negative fp32 denormalized value.
    data = 32'h80000001;
    #5;
    `assert(sign,      1);
    `assert(exponent,  0);
    `assert(mantissa,  1);
    `assert(is_zero,   0);
    `assert(is_denorm, 1);
    `assert(is_inf,    0);
    `assert(is_nan,    0);

    // Smallest representable negative fp32 normalized value.
    data = 32'h80800000;
    #5;
    `assert(sign,      1);
    `assert(exponent,  1);
    `assert(mantissa,  0);
    `assert(is_zero,   0);
    `assert(is_denorm, 0);
    `assert(is_inf,    0);
    `assert(is_nan,    0);

    // Negative infinity.
    data = 32'hff800000;
    #5;
    `assert(sign,      1);
    `assert(exponent,  255);
    `assert(mantissa,  0);
    `assert(is_zero,   0);
    `assert(is_denorm, 0);
    `assert(is_inf,    1);
    `assert(is_nan,    0);

    // NaN.
    data = 32'hff800001;
    #5;
    `assert(sign,      1);
    `assert(exponent,  255);
    `assert(mantissa,  1);
    `assert(is_zero,   0);
    `assert(is_denorm, 0);
    `assert(is_inf,    0);
    `assert(is_nan,    1);

    $display("UNIT TEST PASSED: %m");
  end

endmodule
