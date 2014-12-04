/*
A BLDC motor controller 

Generates the outputs for the driver stage
Gets as input the Hall sensor bits, 
fwd, 
and an enable signal.

has internal state to prevent output glitches. 
needs to be clocked. 
can this be done with an RC from an output(inverter)
back to clk?

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
module bldc(
(*PAD="1"*)
input wire clk,
(*PAD="2"*)
input wire enable,
(*PAD="3"*)
input wire fwd,
/*hall inputs(from a comparator...)*/
(*PAD="5"*)
input wire in_u,
(*PAD="6"*)
input wire in_v,
(*PAD="7"*)
input wire in_w,

/*selectable driver polarity(outputs are active hi if low)*/
(*PAD="8"*)
input wire inv_h,
(*PAD="9"*)
input wire inv_l,
(*PAD="10"*)
input wire reset,

/*for clock gen, inverts clock input*/
(*PAD="23"*)
output wire inv,
(*PAD="22"*)
output reg s_u,
(*PAD="21"*)
output reg s_v,
(*PAD="20"*)
output reg s_w,
/*outputs, deglitched, and'ed with enable, not usable for speed sense*/
(*PAD="19"*)
output wire out_uh,
(*PAD="18"*)
output wire out_vh,
(*PAD="17"*)
output wire out_wh,
(*PAD="16"*)
output wire out_ul,
(*PAD="15"*)
output wire out_vl,
(*PAD="14"*)
output wire out_wl

);

(*PAD="AR"*)
wire rst;

assign rst=reset;

always @(posedge clk or posedge rst)
  if (rst)
  begin
    s_u <= 1'b0;
    s_v <= 1'b0;
    s_w <= 1'b1;
  end
  else
  begin
/*
states:
'forward' rotation u->v->w
u\<-  w
   *  
   v\
   
uvw
001
101
100
110
010
011
..and back
*/
  	/* recovery from all zeroes or ones */
	  if((~s_u && ~s_v && ~s_w) || (s_u && s_v && s_w))
  	begin
	    s_u <= 1'b0;
  	  s_v <= 1'b0;
    	s_w <= 1'b1;
	  end
	  else
  	begin
		  if(fwd)
	 	  begin
	    /*
	    do not step in backward direction
	    If I only allow 1 step in forward direction, there may be a startup state that stalls. 
	    If I disallow 1 step in backward direction, I have to use the sensor bits for next state, 
	    and must also disallow invalid words.
	    */
		 	  if(
		 	  (!((in_u==~s_w)&&(in_v==~s_u)&&(in_w==~s_v)))
          &&(!(~in_u && ~in_v && ~in_w))
          &&(!(in_u && in_v && in_w))
          )
				begin
			    s_u <= in_u;
			    s_v <= in_v;
	  		  s_w <= in_w;
	  		end
	  		else
	  		begin
			    s_u <= s_u;
			    s_v <= s_v;
	  		  s_w <= s_w;
	  		end
	  	end
		  else
	    begin
	    /*
	    do not step in forward direction
	    */
		 	  if(
		 	  (!((in_u==~s_v)&&(in_v==~s_w)&&(in_w==~s_u)))
          &&(!(~in_u && ~in_v && ~in_w))
          &&(!(in_u && in_v && in_w))
          )
		 	  begin
			    s_u <= in_u;
  			  s_v <= in_v;
	  		  s_w <= in_w;
	  	  end
	  		else
	  		begin
			    s_u <= s_u;
			    s_v <= s_v;
	  		  s_w <= s_w;
	  		end
	    end
	  end
	end
/*
logic
forward ...

   v'
u\<-  w
   *  
w' v\ u'

coil drivers u' v' and w'
uvw  u'v'w'uhul
001  H L Z 1 0
101  H Z L 1 0
100  Z H L 0 0
110  L H Z 0 1
010  L Z H 0 1
011  Z L H 0 0

Not sure if the polarity is OK
may need configurable H/L reversal...

The branch is hi if the bit changes from 0 to one
and low if it changes from 1 to zero.
other way around for reverse..

prev s_u is ~s_w
next s_u is ~s_v

if the current bit is 0 and next is 1
or if current bit is 1 and prev is 0
hi is 1
except in reverse, then branches are reversed.. uh<->ul

inv_h inv_l should be hardcoded...

will it cause problems with invalid states? (short circuit?)
because it may take some time to recover from those...
s_u/v/w all zeroes or all ones..
add additional terms to exclude forbidden states
remove complementary terms..
s_u ~s_u...

*/

assign out_uh=(((fwd & s_w & ~s_v) | (~fwd & ~s_w & s_v))&enable)^inv_h;
assign out_ul=( (fwd & s_v & ~s_w) | (~fwd & ~s_v & s_w))^inv_l;

assign out_vh=(((fwd & ~s_w & s_u) | (~fwd & ~s_u & s_w))&enable)^inv_h;
assign out_vl=( (fwd & ~s_u & s_w) | (~fwd & ~s_w & s_u))^inv_l;

assign out_wh=(((fwd & ~s_u & s_v) | (~fwd & ~s_v & s_u))&enable)^inv_h;
assign out_wl=( (fwd & ~s_v & s_u) | (~fwd & ~s_u & s_v))^inv_l;

assign inv=~clk;

endmodule

