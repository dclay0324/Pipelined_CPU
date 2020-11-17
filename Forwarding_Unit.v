`timescale 1ns / 1ps
module Forwarding_Unit(
	EX_MEMRegWrite,
	MEM_WBRegWrite,
	EX_MEMRegisterRd,
	MEM_WBRegisterRd,
	ID_EXRegisterRs1,
	ID_EXRegisterRs2,
	ForwardA,
	ForwardB
	);
input EX_MEMRegWrite, MEM_WBRegWrite;
input [4:0] EX_MEMRegisterRd, MEM_WBRegisterRd, ID_EXRegisterRs1, ID_EXRegisterRs2;
output reg [1:0] ForwardA, ForwardB;

always@(*)begin
// add your code here
	/*ForwardA = (EX_MEMRegWrite && (EX_MEMRegisterRd != 0) 
			&& (EX_MEMRegisterRd == ID_EXRegisterRs1))? 2'b10: 
				(MEM_WBRegWrite && (MEM_WBRegisterRd != 0)
			&& !(EX_MEMRegWrite && (EX_MEMRegisterRd != 0)
			&& (EX_MEMRegisterRd == ID_EXRegisterRs1))
			&& (MEM_WBRegisterRd == ID_EXRegisterRs1))? 2'b01: 0;

	ForwardB = (EX_MEMRegWrite && (EX_MEMRegisterRd != 0) 
			&& (EX_MEMRegisterRd == ID_EXRegisterRs2))? 2'b10: 
				(MEM_WBRegWrite && (MEM_WBRegisterRd != 0)
			&& !(EX_MEMRegWrite && (EX_MEMRegisterRd != 0)
			&& (EX_MEMRegisterRd == ID_EXRegisterRs2))
			&& (MEM_WBRegisterRd == ID_EXRegisterRs2))? 2'b01: 0;*/

	ForwardA = (EX_MEMRegWrite && (EX_MEMRegisterRd != 0) 
			&& (EX_MEMRegisterRd == ID_EXRegisterRs1))? 2'b10: 0;
	ForwardB = (EX_MEMRegWrite && (EX_MEMRegisterRd != 0) 
			&& (EX_MEMRegisterRd == ID_EXRegisterRs2))? 2'b10: 0;
			
	ForwardA = (MEM_WBRegWrite && (MEM_WBRegisterRd != 0)
			&& !(EX_MEMRegWrite && (EX_MEMRegisterRd != 0)
			&& (EX_MEMRegisterRd == ID_EXRegisterRs1))
			&& (MEM_WBRegisterRd == ID_EXRegisterRs1))? 2'b01: ForwardA;
	ForwardB = (MEM_WBRegWrite && (MEM_WBRegisterRd != 0)
			&& !(EX_MEMRegWrite && (EX_MEMRegisterRd != 0)
			&& (EX_MEMRegisterRd == ID_EXRegisterRs2))
			&& (MEM_WBRegisterRd == ID_EXRegisterRs2))? 2'b01: ForwardB;
end

endmodule
