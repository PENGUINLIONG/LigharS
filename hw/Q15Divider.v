`timescale 1ns/1ps

module Q15Divider (
  input clk,
  input reset,
  input launch,
  input signed [63:0] a,
  input signed [63:0] b,

  output busy,
  output nan,
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
  Q15Decoder decode_a(
    .data(b),
    .sign(b_sign),
    .nan (b_nan),
    .zero(b_zero),
    .inf (b_inf)
  );

  wire nan = a_nan | b_nan | b_zero | (a_inf & b_inf);
  wire inf_sign = (a_inf & a_sign) ^ (b_inf & b_sign);
  wire [63:0] inf_res = {inf_sign, 63'h7fffffffffffffff};

  wire signed [68:0] a_extended = {a, 15'b0};
  wire signed [68:0] b_extended = {b, 15'b0};

  wire launch_inner = launch & !a_zero & !b_zero & !a_inf & !a_inf;
  wire div_by_zero;
  wire signed [68:0] quotient_extended;
  Divider #(.WIDTH=69) inner(
    .clk(clk),
    .reset(reset),
    .launch(launch_inner),
    .dividend(a_extended),
    .divisor(b_extended),
    .busy(busy),
    .div_by_zero(div_by_zero),
    .quotient(quotient)
  );

  wire signed [63:0] quotient;

  assign nan = a_nan | b_nan | div_by_zero;
  assign res = 
    nan    ? 64'h8000000000000000 :
    a_inf  ? a :
    b_inf  ? 0 :
    a_zero ? 0 :
             quotient;

endmodule
