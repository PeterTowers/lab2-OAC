/*
Esse deve ser o conteudo do UnicicloInst.mif para estes testbench

--------------------------------
DEPTH = 128;
WIDTH = 32;
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;
CONTENT
BEGIN

00000000 : 24080064; % 3: addiu $t0, $zero, 100 %
00000001 : 3c1003e8; % 5: lui $s0, 1000 %
00000002 : 3c112710; % 6: lui $s1, 10000 %
00000003 : 350903e8; % 7: ori $t1, $t0, 1000 %
00000004 : 390a03e8; % 8: xori $t2, $t0, 1000 %
00000005 : 3c01ffff; % 10: ori $t3, $t0, -1000 %
00000006 : 3421fc18;
00000007 : 01015825;
00000008 : 3c01ffff; % 11: xori $t4, $t0, -1000 %
00000009 : 3421fc18;
0000000a : 01016026;
0000000b : 3c01ffff; % 12: andi $t5, $t0, -1000 %
0000000c : 3421fc18;
0000000d : 01016824;
0000000e : 200f0000; % 15: addi $t7, $zero, 0x00000000 #no MARS é 0x10100000 e no nosso é 0x00000000 %
0000000f : ade80004; % 16: sw $t0, 4($t7) %
00000010 : 8dee0004; % 17: lw $t6, 4($t7) %
00000011 : 8def0008; % 18: lw $t7 8($t7) %
00000012 : 2413ff9c; % 20: li $s3, -100 %
00000013 : 24140064; % 21: li $s4, 100 %
00000014 : 3c01000f; % 22: li $s5, 1000000 %
00000015 : 34354240;

END;
------------------------------------------------*/
`timescale 1ps / 1ps  
module mips_uniciclo_tb8;

	reg pc_clock, inst_clock, data_clock, reg_clock;
	wire[31:0] ALUresult, pc, instruction, alu_operand_a, alu_operand_b;
	wire alu_zero;
	
	mips_uniciclo test_unit(
		.pc_clock(pc_clock), 
		.inst_clock(inst_clock),
		.data_clock(data_clock),
		.reg_clock(reg_clock),
		.ALUresult_out(ALUresult),
		.pc_out(pc),
		.instruction_out(instruction),
		.alu_zero_out(alu_zero),
		.alu_operand_a(alu_operand_a),
		.alu_operand_b(alu_operand_b)
	);
	
	integer i;
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
			if (expected == mips_uniciclo_tb8.test_unit.reg_bank.registers[index])
				$display("$%0d: ok: %h", index, expected);
			else
				$display("$%0d: INCORRECT. Expected 0x%h; got 0x%h", index, expected, mips_uniciclo_tb8.test_unit.reg_bank.registers[index]);
		end
	
	endtask
	
	initial begin
		pc_clock = 1'b0;
		inst_clock = 1'b0;
		data_clock = 1'b0;
		reg_clock = 1'b0;
	end
	
	initial begin	// Temos varios sinais de clock, pois cada componente precisa ser ativado em um momento diferente.
		repeat(num_cycles)
			begin 
				reg_clock = 1'b0;
				pc_clock = 1'b1;
				#50;
				pc_clock = 1'b0;
				inst_clock = 1'b1;
				#250;
				inst_clock = 1'b0;
				data_clock = 1'b1;			
				#250;
				data_clock = 1'b0;
				reg_clock = 1'b1;
				#50;
			end
		test_result_t(
			32'h_64,					//$t0
			32'h_3ec,				//$t1
			32'h_38c,				//$t2
			32'h_fffffc7c,			//$t3
			32'h_fffffc7c,			//$t4
			32'h_0, 					//$t5
			32'h_64,					//$t6
			32'h_0					//$t7
			);
		
		test_result_s(
			32'h_03e80000,			//$s0
			32'h_27100000,			//$s1
			32'h_0,					//$s2
			32'h_ffffff9c,			//$s3
			32'h_64,					//$s4
			32'h_f4240, 			//$s5
			32'h_0,					//$s6
			32'h_0					//$s7
			);	
	end
	
endmodule