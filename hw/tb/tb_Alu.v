`timescale 1ns / 1ps

`define assert(signal, value) \
  if (signal !== value) begin \
      $display("ASSERTION FAILED in %m: signal != value"); \
      $finish; \
  end

`define test_alu(xop, xoperand0, xoperand1, zres) \
  en = 1; \
  op = xop; \
  operand0 = xoperand0; \
  operand1 = xoperand1; \
  #5 clk = ~clk; #5 clk = ~clk; \
  `assert(zero, zres == 0 ? 1 : 0); \
  `assert(neg, zres[31] == 1 ? 1 : 0); \
  `assert(res, zres); \

module tb_Alu;
  reg en;
  reg clk;
  reg [3:0] op;
  reg [31:0] operand0;
  reg [31:0] operand1;

  wire zero;
  wire neg;
  wire [31:0] res;


  Alu uut (
    .en(en),
    .clk(clk),
    .op(op),
    .operand0(operand0),
    .operand1(operand1),
    .zero(zero),
    .neg(neg),
    .res(res)
  );

  localparam ADD = 4'b0000;
  localparam SUB = 4'b0001;
  localparam MUL = 4'b0010;
  localparam DIV = 4'b0011;

  localparam NOT = 4'b1000;
  localparam AND = 4'b1001;
  localparam OR = 4'b1010;
  localparam XOR = 4'b1011;

  localparam LOGIC_SHIFT_LEFT = 4'b1100;
  localparam LOGIC_SHIFT_RIGHT = 4'b1101;
  localparam ARITH_SHIFT_LEFT = 4'b1110;
  localparam ARITH_SHIFT_RIGHT = 4'b1111;

  localparam YES = 1;
  localparam NO = 0;

  localparam ONE = 32'b1;
  localparam TWO = 32'b10;
  localparam THREE = 32'b11;
  localparam ZERO = 32'b0;
  localparam NEG_ONE = ~32'b0;
  localparam POS_MAX = 32'b01111111111111111111111111111111;

  // Test contents.
  initial begin
    clk = 0;
    //       | op | operand0 | operand1 |    res |
    `test_alu( ADD,       ONE,   NEG_ONE,    ZERO); // 1 + (-1) = 0
    `test_alu( ADD,       ONE,       ONE,     TWO); // 1 + 1 = 2
    `test_alu( ADD,      ZERO,   NEG_ONE, NEG_ONE); // 0 + (-1) = -1
    `test_alu( ADD,      ZERO,      ZERO,    ZERO); // 0 + 0 = 0
   
    `test_alu( SUB,       ONE,   NEG_ONE,     TWO); // 1 - (-1) = 2
    `test_alu( SUB,       ONE,       ONE,    ZERO); // 1 - 1 = 0
    `test_alu( SUB,       ONE,       TWO, NEG_ONE); // 1 - 2 = -1
    `test_alu( SUB,       ONE,      ZERO,     ONE); // 1 - 0 = 1
    `test_alu( SUB,      ZERO,       ONE, NEG_ONE); // 0 - 1 = -1

    `test_alu( MUL,       ONE,      ZERO,    ZERO); // 1 * 0 = 0
    `test_alu( MUL,       ONE,       ONE,     ONE); // 1 * 1 = 1
    `test_alu( MUL,       TWO,       ONE,     TWO); // 2 * 1 = 2

    `test_alu( DIV,       TWO,       ONE,     TWO); // 2 / 1 = 2
    `test_alu( DIV,       ONE,       TWO,    ZERO); // 1 / 2 = 0
    `test_alu( DIV,       TWO,       TWO,     ONE); // 2 / 2 = 1

    `test_alu( NOT,       NEG_ONE, 32'bX,    ZERO); // ~(-1) = 0
    `test_alu( AND,       NEG_ONE,   ONE,     ONE); // (-1) & 1 = 0
    `test_alu( AND,       NEG_ONE,   TWO,     TWO); // (-1) & 2 = 2
    `test_alu(  OR,           ONE,   TWO,   THREE); // 1 | 2 = 3
    `test_alu( XOR,         THREE,   TWO,     ONE); // 3 ^ 2 = 1

    `test_alu(  LOGIC_SHIFT_LEFT,         ONE,   ONE,         TWO); // 1 << 1 = 2
    `test_alu( LOGIC_SHIFT_RIGHT,         ONE,   ONE,        ZERO); // 1 >> 1 = 0
    `test_alu( LOGIC_SHIFT_RIGHT,         TWO,   ONE,         ONE); // 2 >> 1 = 1
    `test_alu( LOGIC_SHIFT_RIGHT,     NEG_ONE,   ONE,     POS_MAX); // 2 >> 1 = 1
    `test_alu( ARITH_SHIFT_RIGHT,         ONE,   ONE,        ZERO); // 1 >>> 1 = 0
    `test_alu( ARITH_SHIFT_RIGHT,     NEG_ONE,   ONE,     NEG_ONE); // (-1) >>> 1 = -1

    $display("UNIT TEST PASSED: %m");
  end

endmodule
