module control_unit(
	input[0:6] opcode,
	output reg_dst,
	output branch,
	output read_mem,
	output mem_para_reg,
	output opALU,
	output write_mem,
	output orig_alu,
	output write_reg
	);
	
	
	reg write_reg_out;
	reg reg_dst_out;
	reg branch_out;
	reg read_mem_out;
	reg mem_para_reg_out;
	reg opALU_out;
	reg write_mem_out;
	reg orig_alu_out;
	
	assign write_reg = write_reg_out;
	assign reg_dst = reg_dst_out;
	assign branch = branch_out;
	assign read_mem = read_mem_out;
	assign mem_para_reg = mem_para_reg_out;
	assign opALU = opALU_out;
	assign write_mem = write_mem_out;
	assign orig_alu = orig_alu_out;
	
	initial begin
		write_reg_out = 1'b0;
		reg_dst_out = 1'b0;
		branch_out = 1'b0;
		read_mem_out = 1'b0;
		mem_para_reg_out = 1'b0;
		opALU_out = 1'b0;
		write_mem_out = 1'b0;
		orig_alu_out = 1'b0;	
	end
	
	
	always @(*)
	begin
		case(opcode)
			6'b100000: 
				write_reg_out = 1'b1;
		endcase
	end
	
	
endmodule