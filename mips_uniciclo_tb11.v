/* Este deve ser o conteudo do UnicicloInst.mif para este testbench
/* -----------------------------------------------------------------------------
DEPTH = 128;
WIDTH = 32;
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;												// Estes comentarios marcados
CONTENT															// com '//' nao devem estar
BEGIN																// presentes no arquivo*.mif

00000000 : 3c017fff; % 3: li $t0, 2147483640	%		// t0 = 0x7FFF_FFF8
00000001 : 3428fff8;
00000002 : 3c018000; % 4: li $t1, -2147483640 %		// t1 = 0x8000_0008
00000003 : 34290008;											// -64 = 0xFFFF_FFC0
00000004 : 71095002; % 6: mul $t2, $t0, $t1 %		// t2 = -64
00000005 : 00005810; % 7: mfhi $t3 %					// t3 = 0xC000_0007; 512=0x200
00000006 : 010a0018; % 9: mult $t0, $t2 %				// HI = 0xFFFF_FFE0; LO = 0x200
00000007 : 00006012; % 10: mflo $t4 %					// t4 = 0x200
00000008 : 00006810; % 11: mfhi $t5 %					// t5 = 0xFFFF_FFE0
00000009 : 718d0000; % 13: madd $t4, $t5 %			// HI = 0xFFFF_FFDF; LO = 0xFFFF_C200
0000000a : 00007012; % 14: mflo $t6 %					// t6 = 0xFFFF_C200
0000000b : 00007810; % 15: mfhi $t7 %					// t7 = 0xFFFF_FFDF
0000000c : 710e0005; % 17: msubu $t0, $t6 %			// HI = 0x8000_1ee7; LO = 0xFFFD_D200
0000000d : 00008012; % 19: mflo $s0 %					// s0 = 0xFFFD_D200
0000000e : 00008810; % 20: mfhi $s1 %					// s1 = 8000_1ee7
0000000f : 20120011; % 22: addi $s2, $zero, 17 %	// s2 = 17
00000010 : 0192001a; % 3: div $t4, $s2 %				// HI = 2; LO = 0x1e
00000011 : 00009812; % 25: mflo $s3 %					// s3 = 0x1e (reg 19)
00000012 : 0000a010; % 26: mfhi $s4 %					// s4 = 0x2
00000013 : 0117001a; % 4: div $t0, $s7 %				// NO OP; div_zero = 1
00000014 : 0000a812; % 29: mflo $s5 %					// s5 = 0x1e
00000015 : 0000b010; % 30: mfhi $s6 %					// s6 = 0x2

END;
------------------------------------------------*/
`timescale 1ps / 1ps  
module mips_uniciclo_tb11;

	reg pc_clock, inst_clock, data_clock, reg_clock, muu_clock;
	wire[31:0] pc, instruction, alu_operand_a, alu_operand_b, ALUresult, t0, t1, t2, t3, t4, t5, t6, t7, hi, lo, memory_write;
	wire alu_zero;
	
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
		.memory_write(memory_write)
	);
	
	
	
	parameter num_cycles = 100;
		
	task test_result_t;
		input [31:0] expected_t0, expected_t1, expected_t2, expected_t3, expected_t4, expected_t5, expected_t6, expected_t7;	
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
		input [31:0] expected_s0, expected_s1, expected_s2, expected_s3, expected_s4, expected_s5, expected_s6, expected_s7;	
		begin						
			// >>>>> $a0-$a7
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
			if (expected == mips_uniciclo_tb11.test_unit.reg_bank.registers[index])
				$display("$%0d: ok: %h", index, expected);
			else
				$display("$%0d: INCORRECT. Expected 0x%h; got 0x%h", index, expected, mips_uniciclo_tb11.test_unit.reg_bank.registers[index]);
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
			$display("Register[%0d] = 0x%h", i , mips_uniciclo_tb11.test_unit.reg_bank.registers[i]);
		end
			
		
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
	end
	
endmodule