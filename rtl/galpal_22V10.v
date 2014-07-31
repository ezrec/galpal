/*
 * Copyright (C) 2010, Jason S. McMullan. All rights reserved.
 * Author: Jason S. McMullan <jason.mcmullan@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 */

`include "../rtl/tim15.v"

module galpal_22V10_mux (
	input	S,
	input	[1:0]	I,
	output	O
);

assign O = I[S];

endmodule

module galpal_22V10_dff (
	input	ARX,
	input	SPX,
	input	D,
	input	CLK,
	output	QX,
	output	_QX
);

reg Q;
wire AR;
wire SP;
//goes to feedback
assign #(`TCF_MIN:`TCF_MAX:`TCF_MAX) _QX = !Q;
//goes to output
assign #(`TCO_MIN:`TCO_MAX:`TCO_MAX) QX = Q;
//input to reset of reg
assign #(`TAP_MIN-`TCO_MIN:`TAP_MAX-`TCO_MAX:`TAP_MAX-`TCO_MAX) AR = ARX;
//SP setup time
assign #(`TSP_MIN) SP = SPX;

initial
Q = 1'b0;

always @(posedge AR or posedge CLK)
	if (AR == 1'b1)
    Q <= 1'b0;
	else if (SP == 1'b1)
		Q <= 1'b1;
	else 
		Q <= D;

endmodule

module galpal_22V10_sum #(
	parameter width = 8
	) (
	input [width-1:0] I,
	output O
);

assign O = (I != {width{1'b0}});

endmodule

module galpal_22V10_prod #(
	parameter width = 8
	) (
	input	[width*44 - 1:0] S,
	input	[21:0] I,
	output	O
);

wire [43:0] ini;

wire [width-1:0] prod;

generate
	genvar i;
	for (i = 0; i < 22; i = i + 1) begin : INI
		assign ini[i * 2 + 0] = I[i];
		assign ini[i * 2 + 1] = !I[i];
	end
endgenerate

generate
	genvar j;
	for (j = 0; j < width; j = j + 1) begin : PROD
		wire [43:0] mask;
		
		assign mask =  ini | S[(j + 1) * 44 - 1: j * 44];
		assign prod[j] = (mask == {44{1'b1}});
	end
endgenerate

galpal_22V10_sum #(.width(width)) sum (.I(prod),.O(O));

endmodule

/* galpal_22V10's component macrocell */
module galpal_22V10_olmc (
	input	[1:0] S,
	input	E,		// Enable
	input	AR,
	input	SP,
	input	CLK,
	input	I,		// Input
	output	O,
	output	_O,
	inout	IOQ
);

wire q;
wire _q;

reg o;
wire s0_o;
wire s1o_o;
wire s1q_o;
wire dff_inp;
wire comb_inp;
wire en_out;


always @(s1o_o)
	o <= s1o_o;

assign O = o;
assign _O = !o;
assign #(`TEA_MIN:`TEA_MAX:`TEA_MAX,`TER_MIN:`TER_MAX:`TER_MAX) en_out = E;
assign #`TS_MIN dff_inp=I;
assign #(`TPD_MIN:`TPD_MAX:`TPD_MAX) comb_inp=I;
galpal_22V10_dff dff (.ARX(AR),.SPX(SP),.D(dff_inp),.CLK(CLK),.QX(q),._QX(_q));

//output inversion TCO/TPD/TS/TCF
galpal_22V10_mux s0_mux (.I({!s1q_o,s1q_o}),.O(s0_o),.S(S[0]));
//comb/ff select
galpal_22V10_mux s1q_mux (.I({comb_inp,q}),.O(s1q_o),.S(S[1]));
//feedback path if reg, then ts+tcf, if comb it's tpd('coz ext pin)
galpal_22V10_mux s1o_mux (.I({IOQ,_q}),.O(s1o_o),.S(S[1]));

//out buffer
bufif1(IOQ, !s0_o, en_out);

endmodule

module galpal_22V10 #(
	parameter FUSE = 5892'b1
	) (
	input	I_CLK,		// Pin 1
	input	[11:0]	I,	// Pin 2-11,13
	input	GND,		// Pin 12
	inout	[9:0]   IOQ,	// Pin 14-23
	input	VCC		// Pin 24
);

wire [21:0] prod_in;

wire [9:0] olmc_e;
wire [9:0] olmc_i;
wire [9:0] olmc_o;
/*
assign prod_in = {
	I[0], olmc_o[0],
	I[1], olmc_o[1],
	I[2], olmc_o[2],
	I[3], olmc_o[3],
	I[4], olmc_o[4],
	I[5], olmc_o[5],
	I[6], olmc_o[6],
	I[7], olmc_o[7],
	I[8], olmc_o[8],
	I[9], olmc_o[9],
	I[10],I[11]};
*/

assign prod_in = {
I[11],
I[10],
 olmc_o[9],I[9],
 olmc_o[8],	I[8], 
  olmc_o[7],	I[7],
   olmc_o[6],I[6],
    olmc_o[5],I[5],
     olmc_o[4],
     	I[4],olmc_o[3],
     	I[3],  olmc_o[2],
     	I[2], olmc_o[1],
     	I[1], olmc_o[0],
	I[0]
	};
wire [5891:0] fuse;

assign fuse = FUSE;

wire ar;
galpal_22V10_prod #(.width(1)) prod_ar (.S(fuse[43:0]), .I(prod_in), .O(ar) );

wire sp;
galpal_22V10_prod #(.width(1)) prod_sp (.S(fuse[5807:5764]), .I(prod_in), .O(sp) );

wire clk;
assign clk = I[0];

galpal_22V10_prod #(.width(1)) prod_0_e (
		.S(fuse[87:44]),
		.I(prod_in),
		.O(olmc_e[0]));

galpal_22V10_prod #(.width(8)) prod_0_i (
		.S(fuse[439:88]),
		.I(prod_in),
		.O(olmc_i[0]));

galpal_22V10_olmc olmc_0 (
		.S(fuse[5809:5808]),
		.AR(ar),
		.SP(sp),
		.CLK(clk),
		.E(olmc_e[0]),
		.I(olmc_i[0]),
		.O(olmc_o[0]),
		.IOQ(IOQ[9])
	);

galpal_22V10_prod #(.width(1)) prod_1_e (
		.S(fuse[483:440]),
		.I(prod_in),
		.O(olmc_e[1]));

galpal_22V10_prod #(.width(10)) prod_1_i (
		.S(fuse[923:484]),
		.I(prod_in),
		.O(olmc_i[1]));

galpal_22V10_olmc olmc_1 (
		.S(fuse[5811:5810]),
		.AR(ar),
		.SP(sp),
		.CLK(clk),
		.E(olmc_e[1]),
		.I(olmc_i[1]),
		.O(olmc_o[1]),
		.IOQ(IOQ[8])
	);

galpal_22V10_prod #(.width(1)) prod_2_e (
		.S(fuse[967:924]),
		.I(prod_in),
		.O(olmc_e[2]));

galpal_22V10_prod #(.width(12)) prod_2_i (
		.S(fuse[1495:968]),
		.I(prod_in),
		.O(olmc_i[2]));

galpal_22V10_olmc olmc_2 (
		.S(fuse[5813:5812]),
		.AR(ar),
		.SP(sp),
		.CLK(clk),
		.E(olmc_e[2]),
		.I(olmc_i[2]),
		.O(olmc_o[2]),
		.IOQ(IOQ[7])
	);

galpal_22V10_prod #(.width(1)) prod_3_e (
		.S(fuse[1539:1496]),
		.I(prod_in),
		.O(olmc_e[3]));

galpal_22V10_prod #(.width(14)) prod_3_i (
		.S(fuse[2155:1540]),
		.I(prod_in),
		.O(olmc_i[3]));

galpal_22V10_olmc olmc_3 (
		.S(fuse[5815:5814]),
		.AR(ar),
		.SP(sp),
		.CLK(clk),
		.E(olmc_e[3]),
		.I(olmc_i[3]),
		.O(olmc_o[3]),
		.IOQ(IOQ[6])
	);

galpal_22V10_prod #(.width(1)) prod_4_e (
		.S(fuse[2199:2156]),
		.I(prod_in),
		.O(olmc_e[4]));

galpal_22V10_prod #(.width(16)) prod_4_i (
		.S(fuse[2903:2200]),
		.I(prod_in),
		.O(olmc_i[4]));

galpal_22V10_olmc olmc_4 (
		.S(fuse[5817:5816]),
		.AR(ar),
		.SP(sp),
		.CLK(clk),
		.E(olmc_e[4]),
		.I(olmc_i[4]),
		.O(olmc_o[4]),
		.IOQ(IOQ[5])
	);

galpal_22V10_prod #(.width(1)) prod_5_e (
		.S(fuse[2947:2904]),
		.I(prod_in),
		.O(olmc_e[5]));

galpal_22V10_prod #(.width(16)) prod_5_i (
		.S(fuse[3651:2948]),
		.I(prod_in),
		.O(olmc_i[5]));

galpal_22V10_olmc olmc_5 (
		.S(fuse[5819:5818]),
		.AR(ar),
		.SP(sp),
		.CLK(clk),
		.E(olmc_e[5]),
		.I(olmc_i[5]),
		.O(olmc_o[5]),
		.IOQ(IOQ[4])
	);

galpal_22V10_prod #(.width(1)) prod_6_e (
		.S(fuse[3695:3652]),
		.I(prod_in),
		.O(olmc_e[6]));

galpal_22V10_prod #(.width(14)) prod_6_i (
		.S(fuse[4311:3696]),
		.I(prod_in),
		.O(olmc_i[6]));

galpal_22V10_olmc olmc_6 (
		.S(fuse[5821:5820]),
		.AR(ar),
		.SP(sp),
		.CLK(clk),
		.E(olmc_e[6]),
		.I(olmc_i[6]),
		.O(olmc_o[6]),
		.IOQ(IOQ[3])
	);

galpal_22V10_prod #(.width(1)) prod_7_e (
		.S(fuse[4355:4312]),
		.I(prod_in),
		.O(olmc_e[7]));

galpal_22V10_prod #(.width(12)) prod_7_i (
		.S(fuse[4883:4356]),
		.I(prod_in),
		.O(olmc_i[7]));

galpal_22V10_olmc olmc_7 (
		.S(fuse[5823:5822]),
		.AR(ar),
		.SP(sp),
		.CLK(clk),
		.E(olmc_e[7]),
		.I(olmc_i[7]),
		.O(olmc_o[7]),
		.IOQ(IOQ[2])
	);

galpal_22V10_prod #(.width(1)) prod_8_e (
		.S(fuse[4927:4884]),
		.I(prod_in),
		.O(olmc_e[8]));

galpal_22V10_prod #(.width(10)) prod_8_i (
		.S(fuse[5367:4928]),
		.I(prod_in),
		.O(olmc_i[8]));

galpal_22V10_olmc olmc_8 (
		.S(fuse[5825:5824]),
		.AR(ar),
		.SP(sp),
		.CLK(clk),
		.E(olmc_e[8]),
		.I(olmc_i[8]),
		.O(olmc_o[8]),
		.IOQ(IOQ[1])
	);

galpal_22V10_prod #(.width(1)) prod_9_e (
		.S(fuse[5411:5368]),
		.I(prod_in),
		.O(olmc_e[9]));

galpal_22V10_prod #(.width(8)) prod_9_i (
		.S(fuse[5763:5412]),
		.I(prod_in),
		.O(olmc_i[9]));

galpal_22V10_olmc olmc_9 (
		.S(fuse[5827:5826]),
		.AR(ar),
		.SP(sp),
		.CLK(clk),
		.E(olmc_e[9]),
		.I(olmc_i[9]),
		.O(olmc_o[9]),
		.IOQ(IOQ[0])
	);

endmodule
