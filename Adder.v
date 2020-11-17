module Adder(
    src1_i,
	src2_i,
	sum_o
	);
     
//I/O ports
input  [64-1:0]  src1_i;
input  [64-1:0]	 src2_i;
output [64-1:0]	 sum_o;

//Internal Signals
wire    [64-1:0]	 sum_o;

//Parameter
wire signed [63:0] src1_signed;
wire signed [63:0] src2_signed;
assign src1_signed = src1_i;
assign src2_signed = src2_i;

//Main function
assign sum_o = src1_signed + src2_signed;


endmodule