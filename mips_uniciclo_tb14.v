/* Este deve ser o conteudo do UnicicloInst.mif para este testbench
--------------------------------------------------------------------------------
DEPTH = 128;
WIDTH = 32;
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;
CONTENT
BEGIN

00000000 : 20080200; % 3: addi $t0, $zero, 512 %
00000001 : 34090109; % 4: ori $t1, $zero, 265 %
00000002 : 200af711; % 5: addi $t2, $zero, -2287 %
00000003 : 0109582a; % 7: slt $t3, $t0, $t1	# t0 < t1 ? Nao. t4 = 0 %
00000004 : 0128602a; % 8: slt $t4, $t1, $t0	# t1 < t0 ? Sim. t5 = 1 %
00000005 : 010a682a; % 10: slt $t5, $t0, $t2	# t0 < t2 ? Nao %
00000006 : 0149702a; % 11: slt $t6, $t2, $t1	# t2 < t1 ? Sim %
00000007 : 290f0100; % 13: slti $t7, $t0, 256	# t0 < 256 ? Nao %
00000008 : 29100400; % 14: slti $s0, $t0, 1024	# t0 < 1014 ? Sim %
00000009 : 2951eaef; % 16: slti $s1, $t2, -5393	# t2 < -5393 ? Nao %
0000000a : 2952fbb1; % 17: slti $s2, $t2, -1103	# t2 < -1103 ? Sim %
0000000b : 0148982b; % 19: sltu $s3, $t2, $t0	# |t2| < |t0| ? Nao %
0000000c : 010aa02b; % 20: sltu $s4, $t0, $t2	# |t0| < |t2| ? Sim %

END;
----------------------------------------------------------------------------- */

`timescale 1ps / 1ps  
module mips_uniciclo_tb14;
	reg pc_clock, inst_clock, data_clock, reg_clock, muu_clock;
	wire [31:0] pc, instruction, alu_operand_a, alu_operand_b, ALUresult;
	wire [31:0] t0, t1, t2, t3, t4, t5, t6, t7, hi, lo, memory_write;
	wire [31:0] write_on_bank;
	wire alu_zero, movn, muu_write_enable;
	wire [1:0] write_enable, reg_write;
	
	mips_uniciclo test_unit(
		.pc_clock(pc_clock), 
		.inst_clock(inst_clock),
		.data_clock(data_clock),
		.reg_clock(reg_clock),
		.muu_clock(muu_clock),
		.ALUresult_out(ALUresult),
		.pc_out(pc),
		.instruction_out(instruction),
		.alu_zero_out(alu_zero),
		.movn_out(movn),
		.write_enable_out(write_enable),
		.alu_operand_a(alu_operand_a),
		.alu_operand_b(alu_operand_b),
		.t0(t0),
		.t1(t1),
		.t2(t2),
		.t3(t3),
		.t4(t4),
		.t5(t5),
		.t6(t6),
		.t7(t7),
		.hi(hi),
		.lo(lo),
		.memory_write(memory_write),
		.reg_write_out(reg_write),
		.muu_write_enable_out(muu_write_enable),
		.write_on_bank_out(write_on_bank)
	);
	
	parameter num_cycles = 100;

	initial begin
		pc_clock = 1'b0;
		inst_clock = 1'b0;
		data_clock = 1'b0;
		reg_clock = 1'b0;
		muu_clock = 1'b0;
	end
	
	initial begin	: do_test// Temos varios sinais de clock, pois cada componente precisa ser ativado em um momento diferente.
		integer i, count_empty_instructions;
		count_empty_instructions = 0;
		repeat(num_cycles)
			begin 
				if (count_empty_instructions < 3) begin				
					reg_clock = 1'b0;
					pc_clock = 1'b1;
					#50;
					pc_clock = 1'b0;
					inst_clock = 1'b1;
					#250;
					inst_clock = 1'b0;
					data_clock = 1'b1;
					muu_clock = 1'b1;
					#250;
					data_clock = 1'b0;
					muu_clock = 1'b0;
					reg_clock = 1'b1;
					#50;
					if (instruction == 0)
						count_empty_instructions = count_empty_instructions + 1;
					else
						count_empty_instructions = 0;
				end
			end
			
		for(i = 0; i <=31; i = i + 1) begin
			$display("Register[%0d] = 0x%h", i , mips_uniciclo_tb14.test_unit.reg_bank.registers[i]);
		end
	end
	
endmodule