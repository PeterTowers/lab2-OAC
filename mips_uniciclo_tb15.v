/* Este deve ser o conteudo do UnicicloInst.mif para este testbench
--------------------------------------------------------------------------------
DEPTH = 128;
WIDTH = 32;
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;
CONTENT
BEGIN

00000000 : 20080004; % 3: addi $t0, $zero, 4 %
00000001 : 2009fff8; % 4: addi $t1, $zero, -8 %
00000002 : 00085040; % 6: sll $t2, $t0, 1		# t2 = t0*2 = 8 %
00000003 : 000a5882; % 7: srl $t3, $t2, 2		# t3 = (t1)/4 = 2 %
00000004 : 000960c0; % 9: sll $t4, $t1, 3		# t4 = (-8)*8 = -64 %
00000005 : 00096842; % 10: srl $t5, $t1, 1		# t5 = t1 >> 1 = 0x7fff_fffc %
00000006 : 00087083; % 12: sra $t6, $t0, 2		# t6 = (t0)/4 = 1 %
00000007 : 00097843; % 13: sra $t7, $t1, 1		# t7 = (t1)/2 = -4 %
00000008 : 016d8007; % 15: srav $s0, $t5, $t3	# s0 = (t5)/4 = 0x1fff_ffff %
00000009 : 01ac8807; % 16: srav $s1, $t4, $t5	# s1 = -1 %

END;
----------------------------------------------------------------------------- */

`timescale 1ps / 1ps  
module mips_uniciclo_tb15;
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
			$display("Register[%0d] = 0x%h", i , mips_uniciclo_tb15.test_unit.reg_bank.registers[i]);
		end
	end
	
endmodule