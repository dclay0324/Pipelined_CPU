`timescale 1ns / 1ps
module Pipe_CPU(
        clk_i,
		rst_i
		);
    
/****************************************
*               I/O ports               *
****************************************/
input clk_i;
input rst_i;

/****************************************
*            Internal signal            *
****************************************/

/**** IF stage ****/
//control signal...
wire [32-1:0] pre_instr_w; 
wire [32-1:0] instr_w;
 
wire [64-1:0] pc_addr_w;
wire [64-1:0] pc_addr_ID_w;
wire [64-1:0] pc_addr_EX_w;

wire [64-1:0] Imm_Gen_w; 
wire [64-1:0] Imm_Gen_EX_w; 

wire [64-1:0] shift_left_w;
wire [64-1:0] mux_alusrc_w;
wire [64-1:0] mux3_mux2_w;
wire [64-1:0] mux_alusrc2_w;
wire [64-1:0] mux_pc_result_w;
wire [64-1:0] add2_sum_w;
wire [64-1:0] add2_sum_MEM_w;
wire [4-1:0]  alu_control_w; 
wire [64-1:0] alu_result_w;
wire [64-1:0] alu_result_MEM_w;
wire [64-1:0] alu_result_WB_w;
wire [64-1:0] dataMem_read_w;
wire [64-1:0] dataMem_read_WB_w;
wire [64-1:0] mux_dataMem_result_w; 
wire [64-1:0] rf_rs1_data_w;
wire [64-1:0] rf_rs2_data_w;
wire [64-1:0] rf_rs1_data_EX_w;
wire [64-1:0] rf_rs2_data_EX_w;
wire [64-1:0] mux3_mux2_MEM_w;
wire [64-1:0] add1_result_w;
wire [64-1:0] add1_source_w;
assign add1_source_w = 64'd4;
wire [2-1:0]  ctrl_alu_op_w; 
wire [2-1:0]  ctrl_alu_op_EX_w; 
wire [4:0] if_id_rs1_w;
wire [4:0] if_id_rs2_w;
wire [4:0] if_id_rd_w;
// WB
wire ctrl_register_write_w; 
wire ctrl_register_write_EX_w; 
wire ctrl_register_write_MEM_w; 
wire ctrl_register_write_WB_w; 
wire ctrl_mem_mux_w;
wire ctrl_mem_mux_EX_w;
wire ctrl_mem_mux_MEM_w;
wire ctrl_mem_mux_WB_w;
// MEM
wire ctrl_branch_w;
wire ctrl_branch_EX_w;
wire ctrl_branch_MEM_w;
wire ctrl_mem_read_w;
wire ctrl_mem_read_EX_w;
wire ctrl_mem_read_MEM_w;
wire ctrl_mem_write_w;
wire ctrl_mem_write_EX_w;
wire ctrl_mem_write_MEM_w;
// EX
wire ctrl_alu_mux_w;
wire ctrl_alu_mux_EX_w;
wire alu_zero_w;
wire alu_zero_MEM_w;

wire pc_src_w;
wire and_mux;
wire [4-1:0] alu_ctrl_EX;
wire [5-1:0] write_back_EX;
wire [5-1:0] write_back_MEM;
wire [5-1:0] write_back_WB;
wire [1:0] for_A;
wire [1:0] for_B;

/**** ID stage ****/
//control signal...


/**** EX stage ****/
//control signal...


/**** MEM stage ****/
//control signal...


/**** WB stage ****/
//control signal...


/**** Data hazard ****/
//control signal...

Forwarding_Unit FU(
	.EX_MEMRegWrite(ctrl_register_write_MEM_w),
	.MEM_WBRegWrite(ctrl_register_write_WB_w),
	.EX_MEMRegisterRd(write_back_MEM),
	.MEM_WBRegisterRd(write_back_WB),
	.ID_EXRegisterRs1(if_id_rs1_w),
	.ID_EXRegisterRs2(if_id_rs2_w),
	.ForwardA(for_A),
	.ForwardB(for_B)
	);

/****************************************
*          Instantiate modules          *
****************************************/
//Instantiate the components in IF stage
Program_Counter PC(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.pc_in_i(mux_pc_result_w),
	.pc_out_o(pc_addr_w)
	);

assign pc_src_w = ctrl_branch_MEM_w & alu_zero_MEM_w;	

MUX_2to1 #(.size(64)) Mux_PC_Source(
	.data0_i(add1_result_w),
    .data1_i(add2_sum_MEM_w),
    .select_i(0),
    .data_o(mux_pc_result_w)
	);	

Instr_Mem IM(
	.pc_addr_i(pc_addr_w),
	.instr_o(pre_instr_w)
	);
			
Adder Add_pc(
	.src1_i(pc_addr_w),
	.src2_i(add1_source_w),
	.sum_o(add1_result_w)
	);

//You need to instantiate many pipe_reg
Pipe_Reg #(.size(32)) IF_ID(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(pre_instr_w),
	.data_o(instr_w)
	);

Pipe_Reg #(.size(64)) IF_ID2(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(pc_addr_w),
	.data_o(pc_addr_ID_w)
	);
		
//Instantiate the components in ID stage
//wire regWrite = (ctrl_register_write_WB_w == 2'bx)? 1: ctrl_register_write_WB_w;
Reg_File RF(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.RS1addr_i(instr_w[19:15]) ,
	.RS2addr_i(instr_w[24:20]) ,
	.RDaddr_i(write_back_WB) , // change
	.RDdata_i(mux_dataMem_result_w[64-1:0]),
	.RegWrite_i(ctrl_register_write_WB_w),
	//.RegWrite_i(regWrite),
	.RS1data_o(rf_rs1_data_w[63:0]) ,
	.RS2data_o(rf_rs2_data_w[63:0])
	);

Control Control(
	.instr_op_i(instr_w[6:0]),
	.Branch_o(ctrl_branch_w),
	.MemRead_o(ctrl_mem_read_w),
	.MemtoReg_o(ctrl_mem_mux_w),
	.ALU_op_o(ctrl_alu_op_w[1:0]),
	.MemWrite_o(ctrl_mem_write_w),
	.ALUSrc_o(ctrl_alu_mux_w),
	.RegWrite_o(ctrl_register_write_w)
	);

Imm_Gen IG(
	.data_i(instr_w[32-1:0]),
    .data_o(Imm_Gen_w[64-1:0])
	);	

//You need to instantiate many pipe_reg
Pipe_Reg #(.size(2)) ID_EX(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(ctrl_alu_op_w),
	.data_o(ctrl_alu_op_EX_w)
	);

Pipe_Reg #(.size(1)) ID_EX2(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(ctrl_alu_mux_w),
	.data_o(ctrl_alu_mux_EX_w)
	);

Pipe_Reg #(.size(1)) ID_EX3(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(ctrl_branch_w),
	.data_o(ctrl_branch_EX_w)
	);

Pipe_Reg #(.size(1)) ID_EX4(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(ctrl_mem_read_w),
	.data_o(ctrl_mem_read_EX_w)
	);

Pipe_Reg #(.size(1)) ID_EX5(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(ctrl_mem_write_w),
	.data_o(ctrl_mem_write_EX_w)
	);

Pipe_Reg #(.size(1)) ID_EX6(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(ctrl_register_write_w),
	.data_o(ctrl_register_write_EX_w)
	);

Pipe_Reg #(.size(1)) ID_EX7(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(ctrl_mem_mux_w),
	.data_o(ctrl_mem_mux_EX_w)
	);

Pipe_Reg #(.size(64)) ID_EX8(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(pc_addr_ID_w),
	.data_o(pc_addr_EX_w)
	);

Pipe_Reg #(.size(64)) ID_EX9(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(rf_rs1_data_w),
	.data_o(rf_rs1_data_EX_w)
	);

Pipe_Reg #(.size(64)) ID_EX10(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(rf_rs2_data_w),
	.data_o(rf_rs2_data_EX_w)
	);

Pipe_Reg #(.size(64)) ID_EX11(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(Imm_Gen_w),
	.data_o(Imm_Gen_EX_w)
	);

Pipe_Reg #(.size(4)) ID_EX12(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i({instr_w[30], instr_w[14:12]}),
	.data_o(alu_ctrl_EX)
	);

Pipe_Reg #(.size(5)) ID_EX13(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(instr_w[11:7]),
	.data_o(write_back_EX)
	);

Pipe_Reg #(.size(5)) ID_EX14(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(instr_w[19:15]),
	.data_o(if_id_rs1_w)
	);

Pipe_Reg #(.size(5)) ID_EX15(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(instr_w[24:20]),
	.data_o(if_id_rs2_w)
	);

Pipe_Reg #(.size(5)) ID_EX16(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(instr_w[11:7]),
	.data_o(if_id_rd_w)
	);

//Instantiate the components in EX stage	   
ALU ALU(
	.src1_i(mux_alusrc_w),
	.src2_i(mux_alusrc2_w),
	.ctrl_i(alu_control_w),
	.result_o(alu_result_w),
	.zero_o(alu_zero_w)
	);
		
MUX_3to1 #(.size(64)) Mux3_1(
	.data0_i(rf_rs1_data_EX_w),
    .data1_i(mux_dataMem_result_w),
	.data2_i(alu_result_MEM_w),
    .select_i(for_A),
    .data_o(mux_alusrc_w)
    );
		
MUX_3to1 #(.size(64)) Mux3_2(
	.data0_i(rf_rs2_data_EX_w),
    .data1_i(mux_dataMem_result_w),
	.data2_i(alu_result_MEM_w),
    .select_i(for_B),
    .data_o(mux3_mux2_w)
    );
		
ALU_Ctrl AC(
	.funct_i(alu_ctrl_EX),
    .ALUOp_i(ctrl_alu_op_EX_w),
    .ALUCtrl_o(alu_control_w)
	);

MUX_2to1 #(.size(64)) Mux1(
	.data0_i(mux3_mux2_w),
    .data1_i(Imm_Gen_EX_w),
    .select_i(ctrl_alu_mux_EX_w),
    .data_o(mux_alusrc2_w)
    );
				
Shift_Left_One_64 Shifter(
	.data_i(Imm_Gen_EX_w),
    .data_o(shift_left_w)
	); 	
		
Adder Add_pc2(
	.src1_i(pc_addr_EX_w),
	.src2_i(shift_left_w),
	.sum_o(add2_sum_w)
	);

//You need to instantiate many pipe_reg
Pipe_Reg #(.size(1)) EX_MEM(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(ctrl_branch_EX_w),
	.data_o(ctrl_branch_MEM_w)
	);	

Pipe_Reg #(.size(1)) EX_MEM2(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(ctrl_mem_mux_EX_w),
	.data_o(ctrl_mem_mux_MEM_w)
	);

Pipe_Reg #(.size(1)) EX_MEM3(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(ctrl_mem_read_EX_w),
	.data_o(ctrl_mem_read_MEM_w)
	);

Pipe_Reg #(.size(1)) EX_MEM4(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(ctrl_mem_write_EX_w),
	.data_o(ctrl_mem_write_MEM_w)
	);

Pipe_Reg #(.size(1)) EX_MEM5(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(ctrl_register_write_EX_w),
	.data_o(ctrl_register_write_MEM_w)
	);	

Pipe_Reg #(.size(64)) EX_MEM6(
	.rst_i(rst_i),
	.clk_i(clk_i),    
	.data_i(add2_sum_w),
	.data_o(add2_sum_MEM_w)
	);

Pipe_Reg #(.size(1)) EX_MEM7(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(alu_zero_w),
	.data_o(alu_zero_MEM_w)
	);

Pipe_Reg #(.size(64)) EX_MEM8(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(alu_result_w),
	.data_o(alu_result_MEM_w)
	);

Pipe_Reg #(.size(64)) EX_MEM9(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(mux3_mux2_w),
	.data_o(mux3_mux2_MEM_w)
	);	

Pipe_Reg #(.size(5)) EX_MEM10(
	.rst_i(rst_i),
	.clk_i(clk_i),    
	.data_i(write_back_EX),
	.data_o(write_back_MEM)
	);

//Instantiate the components in MEM stage
Data_Mem DM(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.addr_i(alu_result_MEM_w),
	.data_i(mux3_mux2_MEM_w),
	.MemRead_i(ctrl_mem_read_MEM_w),
	.MemWrite_i(ctrl_mem_write_MEM_w),
	.data_o(dataMem_read_w)
	);

Pipe_Reg #(.size(1)) MEM_WB(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(ctrl_register_write_MEM_w),
	.data_o(ctrl_register_write_WB_w)
	);

Pipe_Reg #(.size(1)) MEM_WB2(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(ctrl_mem_mux_MEM_w),
	.data_o(ctrl_mem_mux_WB_w)
	);

Pipe_Reg #(.size(64)) MEM_WB3(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(dataMem_read_w),
	.data_o(dataMem_read_WB_w)
	);

Pipe_Reg #(.size(64)) MEM_WB4(
	.rst_i(rst_i),
	.clk_i(clk_i),   
	.data_i(alu_result_MEM_w),
	.data_o(alu_result_WB_w)
	);

Pipe_Reg #(.size(5)) MEM_WB5(
	.rst_i(rst_i),
	.clk_i(clk_i),    
	.data_i(write_back_MEM),
	.data_o(write_back_WB)
	);


//Instantiate the components in WB stage
MUX_2to1 #(.size(64)) Mux2(
	.data0_i(alu_result_WB_w),
    .data1_i(dataMem_read_WB_w),
    .select_i(ctrl_mem_mux_WB_w),
    .data_o(mux_dataMem_result_w)
    );

/****************************************
*           Signal assignment           *
****************************************/
	
endmodule

