/*
testvector generator.
Is supposed to write testvectors
for 22V10 to stdout requires a delay parameter to
wait for the outputs to settle

if any of the inputs change, wait a bit,
then dump the pins as testvector

gets the I/O pins as input..

problem:
what with I/O pins cfg as input?

output stuff like this:

V0001 01XXXXX11X1NXZZLLLHHLLXN*
V0002 11XXXXX11X1NXZZLLLHHLLXN*
V0003 001XX010110N0ZZLLLHHLLXN*
V0004 101XX010110N0LLHHLLHHLXN*
V0005 010XX010110N0LLHHLLHHLXN*

pin1 is leftmost
power pins are 'N'
input pins set to either 0,1,or X

output pins tested for L,H or Z or not tested (X)

appending to a jedec file and adding a QV0005
at the header should work with test equipment
 
*/

module testvec #(
	parameter io_dly=15
	) (
	input [11:0] I, 
	input [9:0] O
);

	integer vecnum;
	integer i;
	initial
	begin
    i=0;
		vecnum=1;
	end

	always @(I)
	begin

	if(vecnum<10)
  	$write ("V000%0d ",vecnum);
  else if(vecnum<100)
  	$write ("V00%0d ",vecnum);
  else if(vecnum<1000)
  	$write ("V0%0d ",vecnum);
  else
  	$write ("V%0d ",vecnum);
 
	for (i=0; i<11; i=i+1)
	begin
		if(I[i]===1'b0)
                  $write ("0");
  	else if(I[i]===1'b1)
                  $write ("1");
	  else if(I[i]===1'bx)
                  $write ("X");
  	else if(I[i]===1'bz)
                  $write ("X");
	end

                  $write ("N");
	
	i=11;
	if(I[i]===1'b0)
                  $write ("0");
  else if(I[i]===1'b1)
                  $write ("1");
  else if(I[i]===1'bx)
                  $write ("X");
  else if(I[i]===1'bz)
                  $write ("X");

#io_dly
	for (i=0; i<10; i=i+1)
	begin
		if(O[i]===1'b0)
                  $write ("L");
		else if(O[i]===1'b1)
                  $write ("H");
		else if(O[i]===1'bz)
                  $write ("Z");
		else if(O[i]===1'bx)
                  $write ("X");
  end
                  $write ("N*\n");
  vecnum=vecnum+1;
end

endmodule

