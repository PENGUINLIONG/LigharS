`timescale 1ns / 1ps
// Variable-length non-negative integer divider.

module Divider #(parameter WIDTH=4) (
  input clk,
  input reset,
  input launch,
  input [WIDTH-1:0] dividend,
  input [WIDTH-1:0] divisor,

  output reg busy,
  output reg div_by_zero,
  output [WIDTH-1:0] quotient,
  output [WIDTH-1:0] remainder
);
  reg [WIDTH-1:0] divisor_;  // copy of divisor
  reg [WIDTH-1:0] quotient_; // intermediate quotient
  reg [WIDTH:0] remainder_;  // accumulator (1 bit wider)

  reg [$clog2(WIDTH):0] it_count;

  wire div_digit = remainder_ >= divisor_ ? 1 : 0;
  assign quotient = quotient_;
  assign remainder = remainder_[WIDTH-1:0];

  wire [WIDTH:0] remainder_minus_divisor = remainder_ - divisor_;
  wire [WIDTH:0] remainder_updated = div_digit ?
    {remainder_minus_divisor[WIDTH-1:0], quotient[WIDTH-1]} :
    {remainder, quotient[WIDTH-1]};

  wire [$clog2(WIDTH):0] next_it_count  = it_count + 1;
  wire [WIDTH-1:0]       next_quotient  = launch ?
    {dividend[WIDTH-2:0], 1'b0} :
    {quotient[WIDTH-2:0], div_digit};
  wire [WIDTH:0]         next_remainder = launch ?
    {{(WIDTH-1){1'b0}}, dividend[WIDTH-1]} :
    remainder_updated;

  always @(posedge clk, posedge reset) begin
    if (reset) begin
      busy <= 0;
      div_by_zero <= 0;
      it_count <= 0;
      divisor_ <= 0;
      quotient_ <= 0;
      remainder_ <= 0;
    end else if (launch) begin
      if (divisor == 0) begin
        // Divide by zero, throw an exception instead of actualy getting stuck
        // in a infinite loop.
        busy <= 0;
        div_by_zero <= 1;
        it_count <= 0;
        divisor_ <= 0;
        quotient_ <= 0;
        remainder_ <= 0;
      end else begin
        // Launch the division task.
        busy <= 1;
        div_by_zero <= 0;
        it_count <= 0;
        divisor_ <= divisor;
        quotient_ <= next_quotient;
        remainder_ <= next_remainder;
      end
    end else if (busy) begin
      if (next_it_count == WIDTH) begin
        // Finished.
        busy <= 0;
        div_by_zero <= 0;
        it_count <= 0;
        divisor_ <= divisor_;
        quotient_ <= next_quotient;
        remainder_ <= next_remainder;
      end else begin
        // Next iteration.
        busy <= 1;
        div_by_zero <= 0;
        it_count <= next_it_count;
        divisor_ <= divisor_;
        quotient_ <= next_quotient;
        remainder_ <= next_remainder;
      end

    end
  end
endmodule
