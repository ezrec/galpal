/*
 * A D-type flip-flop to check synchronous logic works
 * correctly.
 */


module dff(
(* PAD="14"*)
output wire q1, 
(* PAD="15"*)
output wire q2, 
(* PAD="16"*)
output wire q3, 
(* PAD="17"*)
output wire q4, 
(* PAD="3"*)
input wire d, 
(* PAD="1"*)
input wire clk, 
(* PAD="2"*)
input wire rstin,
(* PAD="4"*)
input wire ce,
(* PAD="5"*)
input wire oe);

(* PAD="AR"*)
wire rst;
assign rst=rstin;

reg q1a;
reg q2a;
reg q3a;
reg q4a;

//those two should reset to zero
notif1(q1,q1a,oe);
bufif1(q2,q2a,oe);
//those should reset to 1
notif1(q3,q3a,oe);
bufif1(q4,q4a,oe);

  always @(posedge clk)// or posedge rst)
    if (rst)
      q1a <= 1'b1;
    else
	    if(ce)
	    q1a <= d;

  always @(posedge clk or posedge rst)
    if (rst)
      q2a <= 1'b0;
    else
	    if(ce)
  	    q2a <= d;
  
  always @(posedge clk or posedge rst)
    if (rst)
      q3a <= 1'b0;
    else
	    if(ce)
  	    q3a <= d;
  
  always @(posedge clk or posedge rst)
    if (rst)
      q4a <= 1'b1;
    else
	    if(ce)
  	    q4a <= d;

endmodule // dff
