module ALU(
    src1_i,
	src2_i,
	ctrl_i,
	result_o,
	zero_o
	);
  
//I/O ports
input  [64-1:0]  src1_i;
input  [64-1:0]	 src2_i;
input  [4-1:0]   ctrl_i;

output [64-1:0]	 result_o;
output           zero_o;

//Internal signals
reg    [64-1:0]  result_o;
wire             zero_o;

//Parameter
wire signed [63:0] src1_signed;
wire signed [63:0] src2_signed;

assign src1_signed = src1_i;
assign src2_signed = src2_i;

//Main function
always @(*) begin
	case (ctrl_i)
		4'b0000: begin
			result_o = src1_signed & src2_signed;
		end 
		4'b0001: begin
			result_o = src1_signed | src2_signed;
		end 
		4'b0010: begin
			result_o = src1_signed + src2_signed;
		end 
		4'b0110: begin
			result_o = src1_signed - src2_signed;
		end 
		4'b0111: begin
			result_o = (src2_signed > src1_signed)? 1: 0;
		end
		default: begin
		end
	endcase
end
assign zero_o = (src1_i == src2_i)? 1: 0;

endmodule