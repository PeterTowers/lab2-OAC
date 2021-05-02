/* Este deve ser o conteudo do UnicicloInst.mif para este testbench
/* -----------------------------------------------------------------------------
DEPTH = 128;
WIDTH = 32;
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;
CONTENT
BEGIN

00000000 : 2008ffff; % 2: addi $t0, $zero, -1 %
00000001 : 20090100; % 3: addi $t1, $zero, 256 %
00000002 : 010b500b; % 4: movn $t2, $t0, $t3    # t3 = 0, n deve funcionar %
00000003 : 0128580b; % 5: movn $t3, $t1, $t0    # t0 != 0, t3 = t1 = 256 %
00000004 : 0109600b; % 6: movn $t4, $t0, $t1    # t1 != 0, t4 = t0 = -1 %

END;
----------------------------------------------------------------------------- */

`timescale 1ps / 1ps  
module mips_uniciclo_tb13;
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

	task test_result_t;
		input [31:0] expected_t0, expected_t1, expected_t2, expected_t3;
		input [31:0] expected_t4, expected_t5, expected_t6, expected_t7;
		
		begin						
			// >>>>> $t0-$t7
			test_result_unit(5'd8, expected_t0);
			test_result_unit(5'd9, expected_t1);
			test_result_unit(5'd10, expected_t2);
			test_result_unit(5'd11, expected_t3);
			test_result_unit(5'd12, expected_t4);
			test_result_unit(5'd13, expected_t5);
			test_result_unit(5'd14, expected_t6);
			test_result_unit(5'd15, expected_t7);			
		end
	endtask
	
	task test_result_s;
		input [31:0] expected_s0, expected_s1, expected_s2, expected_s3;
		input [31:0] expected_s4, expected_s5, expected_s6, expected_s7;
		
		begin						
			// >>>>> $s0-$s7
			test_result_unit(5'd16, expected_s0);
			test_result_unit(5'd17, expected_s1);
			test_result_unit(5'd18, expected_s2);
			test_result_unit(5'd19, expected_s3);
			test_result_unit(5'd20, expected_s4);
			test_result_unit(5'd21, expected_s5);
			test_result_unit(5'd22, expected_s6);
			test_result_unit(5'd23, expected_s7);			
		end
	endtask
	
	task test_result_t_extra;
		input [31:0] expected_t8, expected_t9;
		begin						
			// >>>>> $t8-$t9			
			test_result_unit(5'd24, expected_t8);
			test_result_unit(5'd25, expected_t9);			
		end
	endtask
	
	task test_result_unit;
		input [4:0] index;
		input [31:0] expected;
		begin
			if (expected == mips_uniciclo_tb13.test_unit.reg_bank.registers[index])
				$display("$%0d: ok: %h", index, expected);
			else
				$display("$%0d: INCORRECT. Expected 0x%h; got 0x%h", index,
							expected,
							mips_uniciclo_tb13.test_unit.reg_bank.registers[index]);
/*----------------------------------------------------------------------------*/
		end
	
	endtask
	
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
			$display("Register[%0d] = 0x%h", i , mips_uniciclo_tb13.test_unit.reg_bank.registers[i]);
		end
	end
	
endmodule

/* Versao antiga da validacao dos testes */
//		test_result_t(
//			32'h_7fff_fff8,	//$t0
//			32'h_8000_0008,		//$t1
//			32'h_ffff_ffc0,		//$t2
//			32'h_c000_0007,		//$t3
//			32'h_200,				//$t4
//			32'h_ffff_ffe0,			//$t5
//			32'h_ffff_c200,				//$t6
//			32'h_ffff_ffdf			//$t7
//			);
//		
//		
//		test_result_s(
//			32'h_fffdd200,			//$s0
//			32'h_8000_1ee7,			//$s1
//			32'h_0,			//$s2
//			32'h_0,			//$s3
//			32'h_0,			//$s4
//			32'h_0, 			//$s5
//			32'h_0,			//$s6
//			32'h_0			//$s7
//			);	
	