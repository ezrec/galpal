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
`default_nettype none
`timescale 1ns/100ps

module bldc_bench (
);

reg [11:0] I;
wire [9:0] O;

bldc dut (
	.I(I),
	.IOQ(O),
	.VCC(1'b1),
	.GND(1'b0)
);

//21 nS 'coz the reset takes possibly 20 nS on 15nS grade parts
testvec #(.io_dly(21))tvo  (
	.I(I),
	.O(O)
);

integer i;

//uvw
`define S0 3'b001
`define S1 3'b101
`define S2 3'b100
`define S3 3'b110
`define S4 3'b010
`define S5 3'b011

initial begin
	$dumpfile("bldc.vcd");
	$dumpvars(16, bldc_bench);
/*
         _____
clk    -|  U  |- VCC
enable -|     |- inv
fwd    -|     |- s_u
()     -|     |- s_v
in_u   -|     |- s_w
in_v   -|     |- out_uh
in_w   -|     |- out_vh
inv_h  -|     |- out_wh
inv_l  -|     |- out_ul
reset  -|     |- out_vl
()     -|     |- out_wl
GND    -|_____|- ()
*/
//  #100 
   I=0;
   I[0] = 0;
   I[1] = 1;
   I[2] = 1;
   I[7] = 0;
   I[8] = 0;
   I[9] = 0;
   #100 I[9] = 1;
   #100 I[9] = 0;

   #500 {I[4],I[5],I[6]} = `S0;
   #100 {I[4],I[5],I[6]} = `S5;
   #100 {I[4],I[5],I[6]} = `S0;
   
   #500 {I[4],I[5],I[6]} = `S1;
   #100 {I[4],I[5],I[6]} = `S0;
   #100 {I[4],I[5],I[6]} = `S1;
   
   #500 {I[4],I[5],I[6]} = `S2;
   #100 {I[4],I[5],I[6]} = `S1;
   #100 {I[4],I[5],I[6]} = `S2;
   
   #500 {I[4],I[5],I[6]} = `S3;
   #100 {I[4],I[5],I[6]} = `S2;
   #100 {I[4],I[5],I[6]} = `S3;
   
   #500 {I[4],I[5],I[6]} = `S4;
   #100 {I[4],I[5],I[6]} = `S3;
   #100 {I[4],I[5],I[6]} = `S4;
   
   #500 {I[4],I[5],I[6]} = `S5;
   #100 {I[4],I[5],I[6]} = `S4;
   #100 {I[4],I[5],I[6]} = `S5;
   
   #500 {I[4],I[5],I[6]} = `S0;
   #100 {I[4],I[5],I[6]} = `S5;
   #100 {I[4],I[5],I[6]} = `S0;
   
   #500 {I[4],I[5],I[6]} = `S1;
   #100 {I[4],I[5],I[6]} = `S0;
   #100 {I[4],I[5],I[6]} = `S1;
	$finish;
end

initial
forever
begin 
   #50 I[0] = 1;
   #50 I[0] = 0;
end


endmodule
