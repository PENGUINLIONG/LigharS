`timescale 1ns/1ps

module Q15ToFp32 (
  input signed [63:0] q15_data,
  input [31:0] fp32_data
);

  wire sign = q15_data[63];
  wire [63:0] unsigned_q15 = sign ? -q15_data : q15_data;

  wire [7:0] exponent;
  wire [22:0] mantissa;
  assign {exponent, mantissa} =
    unsigned_q15[62] == 1 ? {8'd141, unsigned_q15[61:39]} :
    unsigned_q15[61] == 1 ? {8'd140, unsigned_q15[60:38]} :
    unsigned_q15[60] == 1 ? {8'd139, unsigned_q15[59:37]} :
    unsigned_q15[59] == 1 ? {8'd138, unsigned_q15[58:36]} :
    unsigned_q15[58] == 1 ? {8'd137, unsigned_q15[57:35]} :
    unsigned_q15[57] == 1 ? {8'd136, unsigned_q15[56:34]} :
    unsigned_q15[56] == 1 ? {8'd135, unsigned_q15[55:33]} :
    unsigned_q15[55] == 1 ? {8'd134, unsigned_q15[54:32]} :
    unsigned_q15[54] == 1 ? {8'd133, unsigned_q15[53:31]} :
    unsigned_q15[53] == 1 ? {8'd132, unsigned_q15[52:30]} :
    unsigned_q15[52] == 1 ? {8'd131, unsigned_q15[51:29]} :
    unsigned_q15[51] == 1 ? {8'd130, unsigned_q15[50:28]} :
    unsigned_q15[50] == 1 ? {8'd129, unsigned_q15[49:27]} :
    unsigned_q15[49] == 1 ? {8'd128, unsigned_q15[48:26]} :
    unsigned_q15[48] == 1 ? {8'd127, unsigned_q15[47:25]} :
    unsigned_q15[47] == 1 ? {8'd126, unsigned_q15[46:24]} :
    unsigned_q15[46] == 1 ? {8'd125, unsigned_q15[45:23]} :
    unsigned_q15[45] == 1 ? {8'd124, unsigned_q15[44:22]} :
    unsigned_q15[44] == 1 ? {8'd123, unsigned_q15[43:21]} :
    unsigned_q15[43] == 1 ? {8'd122, unsigned_q15[42:20]} :
    unsigned_q15[42] == 1 ? {8'd121, unsigned_q15[41:19]} :
    unsigned_q15[41] == 1 ? {8'd120, unsigned_q15[40:18]} :
    unsigned_q15[40] == 1 ? {8'd119, unsigned_q15[39:17]} :
    unsigned_q15[39] == 1 ? {8'd118, unsigned_q15[38:16]} :
    unsigned_q15[38] == 1 ? {8'd117, unsigned_q15[37:15]} :
    unsigned_q15[37] == 1 ? {8'd116, unsigned_q15[36:14]} :
    unsigned_q15[36] == 1 ? {8'd115, unsigned_q15[35:13]} :
    unsigned_q15[35] == 1 ? {8'd114, unsigned_q15[34:12]} :
    unsigned_q15[34] == 1 ? {8'd113, unsigned_q15[33:11]} :
    unsigned_q15[33] == 1 ? {8'd112, unsigned_q15[32:10]} :
    unsigned_q15[32] == 1 ? {8'd111, unsigned_q15[31:09]} :
    unsigned_q15[31] == 1 ? {8'd110, unsigned_q15[30:08]} :
    unsigned_q15[30] == 1 ? {8'd109, unsigned_q15[29:07]} :
    unsigned_q15[29] == 1 ? {8'd108, unsigned_q15[28:06]} :
    unsigned_q15[28] == 1 ? {8'd107, unsigned_q15[27:05]} :
    unsigned_q15[27] == 1 ? {8'd106, unsigned_q15[26:04]} :
    unsigned_q15[26] == 1 ? {8'd105, unsigned_q15[25:03]} :
    unsigned_q15[25] == 1 ? {8'd104, unsigned_q15[24:02]} :
    unsigned_q15[24] == 1 ? {8'd103, unsigned_q15[23:01]} :
    unsigned_q15[23] == 1 ? {8'd102, unsigned_q15[22:00]} :
    unsigned_q15[22] == 1 ? {8'd101, unsigned_q15[21:00]} :
    unsigned_q15[21] == 1 ? {8'd100, unsigned_q15[20:00], 1'b0} :
    unsigned_q15[20] == 1 ? {8'd099, unsigned_q15[19:00], 2'b0} :
    unsigned_q15[19] == 1 ? {8'd098, unsigned_q15[18:00], 3'b0} :
    unsigned_q15[18] == 1 ? {8'd097, unsigned_q15[17:00], 4'b0} :
    unsigned_q15[17] == 1 ? {8'd096, unsigned_q15[16:00], 5'b0} :
    unsigned_q15[16] == 1 ? {8'd095, unsigned_q15[15:00], 6'b0} :
    unsigned_q15[15] == 1 ? {8'd094, unsigned_q15[14:00], 7'b0} :
    unsigned_q15[14] == 1 ? {8'd093, unsigned_q15[13:00], 8'b0} :
    unsigned_q15[13] == 1 ? {8'd092, unsigned_q15[12:00], 9'b0} :
    unsigned_q15[12] == 1 ? {8'd091, unsigned_q15[11:00], 10'b0} :
    unsigned_q15[11] == 1 ? {8'd090, unsigned_q15[10:00], 11'b0} :
    unsigned_q15[10] == 1 ? {8'd089, unsigned_q15[09:00], 12'b0} :
    unsigned_q15[19] == 1 ? {8'd088, unsigned_q15[08:00], 13'b0} :
    unsigned_q15[08] == 1 ? {8'd087, unsigned_q15[07:00], 14'b0} :
    unsigned_q15[07] == 1 ? {8'd086, unsigned_q15[06:00], 15'b0} :
    unsigned_q15[06] == 1 ? {8'd085, unsigned_q15[05:00], 16'b0} :
    unsigned_q15[05] == 1 ? {8'd084, unsigned_q15[04:00], 17'b0} :
    unsigned_q15[04] == 1 ? {8'd083, unsigned_q15[03:00], 18'b0} :
    unsigned_q15[03] == 1 ? {8'd082, unsigned_q15[02:00], 19'b0} :
    unsigned_q15[02] == 1 ? {8'd081, unsigned_q15[01:00], 20'b0} :
    unsigned_q15[01] == 1 ? {8'd080, unsigned_q15[00:00], 21'b0} :
    unsigned_q15[00] == 1 ? {8'd079, 23'b0} :
    0;

  assign fp32_data = 
    q15_data == 64'h8000000000000000 ? 32'h7fc00000 :
    q15_data == 64'h7fffffffffffffff ? 32'h7f800000 :
    q15_data == 64'h8000000000000001 ? 32'hff800000 :
    {sign, exponent, mantissa};

endmodule
