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
`timescale 1ns/1ps

module GAL22V10_io_bench (
);

reg [11:0] I;
wire [9:0] O;

GAL22V10_io dut (
	.I(I),
	.IOQ(O),
	.VCC(1'b1),
	.GND(1'b0)
);

integer i;

initial begin
	$dumpfile("tb.vcd");
	$dumpvars(16, GAL22V10_io_bench);

	for (i = 0; i < (1 << 12); i = i + 1)
		#100 I = i;
	
	$finish;
end


endmodule
