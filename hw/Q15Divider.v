`timescale 1ns/1ps

module Q15Divider (
  input clk,
  input reset,
  input launch,
  input signed [63:0] a,
  input signed [63:0] b,

  output busy,
  output signed [63:0] res
);

  wire a_sign, a_nan, a_zero, a_inf;
  Q15Decoder decode_a(
    .data(a),
    .sign(a_sign),
    .nan (a_nan),
    .zero(a_zero),
    .inf (a_inf)
  );
  wire b_sign, b_nan, b_zero, b_inf;
  Q15Decoder decode_b(
    .data(b),
    .sign(b_sign),
    .nan (b_nan),
    .zero(b_zero),
    .inf (b_inf)
  );

  wire nan = a_nan | b_nan | b_zero | (a_inf & b_inf) | div_by_zero;
  wire res_sign = a_sign ^ b_sign;
  
  wire [63:0] a_unsigned = a_sign ? -a : a;
  wire [63:0] b_unsigned = b_sign ? -b : b;

  wire [111:0] a_extended = {a_unsigned, 48'b0};
  wire [111:0] b_extended = {48'b0, b_unsigned};

  wire launch_inner = launch & !a_zero & !b_zero & !a_inf & !a_inf;
  wire div_by_zero;
  wire [111:0] quotient_extended;
  wire [63:0] quotient = quotient_extended[63:0];
  Divider #(.WIDTH(112)) inner(
    .clk(clk),
    .reset(reset),
    .launch(launch_inner),
    .dividend(a_extended),
    .divisor(b_extended),
    .busy(busy),
    .div_by_zero(div_by_zero),
    .quotient(quotient_extended)
  );


  assign res = 
    nan    ? 64'h8000000000000000 :
    a_inf  ? a :
    b_inf  ? 0 :
    a_zero ? 0 :
    (res_sign ? -quotient : quotient);

endmodule
