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

module DFF_bench (
);

reg [11:0] I;
wire [9:0] O;

dff2 dut (
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

initial begin
	$dumpfile("tb.vcd");
	$dumpvars(16, DFF_bench);
//  #100 
  I=0;
	#30 I[3]=1;//ce
	#30 I[4]=1;//oe
	#30 I[1]=1;
	#30 I[1]=0;

	#30 I[0]=1;
	#30 I[0]=0;
//d
	#30 I[2]=0;
	
	#30 I[0]=1;
	#30 I[0]=0;
//d
	#30 I[2]=1;
	
	#30 I[0]=1;
	#30 I[0]=0;
	//reset
	#30 I[1]=1;
	#30 I[1]=0;
//d
	#30 I[2]=1;
	
	#30 I[0]=1;
	#30 I[0]=0;
	//d
	#30 I[2]=0;
	
	#30 I[0]=1;
	#30 I[0]=0;
//reset
	#30 I[1]=1;
	#30 I[1]=0;

	#30 I[3]=0;//ce

	//d
	#30 I[2]=0;
	
	#30 I[0]=1;
	#30 I[0]=0;

	//d
	#30 I[2]=1;
	
	#30 I[0]=1;
	#30 I[0]=0;
	
	$finish;
end


endmodule
