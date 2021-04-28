/*
Esse deve ser o conteudo do UnicicloInst.mif para estes testbench

--------------------------------
DEPTH = 128;
WIDTH = 32;
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;
CONTENT
BEGIN

00000000 : 20080064; % 2: addi $t0, $zero, 100 %
00000001 : 2009ff9c; % 3: addi $t1, $zero, -100 %
00000002 : 0109502a; % 4: slt $t2, $t0, $t1 %
00000003 : 0128582a; % 5: slt $t3, $t1, $t0 %
00000004 : 20080064; % 7: addi $t0, $zero, 100 %
00000005 : 2009000a; % 8: addi $t1, $zero, 10 %
00000006 : 0109602a; % 9: slt $t4, $t0, $t1 %
00000007 : 0128682a; % 10: slt $t5, $t1, $t0 %
00000008 : 2008ff9c; % 12: addi $t0, $zero, -100 %
00000009 : 2009fff6; % 13: addi $t1, $zero, -10 %
0000000a : 0109702a; % 14: slt $t6, $t0, $t1 %
0000000b : 0128782a; % 15: slt $t7, $t1, $t0 %
0000000c : 20080000; % 17: addi $t0, $zero, 0 %
0000000d : 20090000; % 18: addi $t1, $zero, 0 %
0000000e : 0109802a; % 19: slt $s0, $t0, $t1 %
0000000f : 0128882a; % 20: slt $s1, $t1, $t0 %

END;
------------------------------------------------*/
`timescale 1ps / 1ps  
module mips_uniciclo_tb9;

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
			if (expected == mips_uniciclo_tb9.test_unit.reg_bank.registers[index])
				$display("$%0d: ok: %h", index, expected);
			else
				$display("$%0d: INCORRECT. Expected 0x%h; got 0x%h", index, expected, mips_uniciclo_tb9.test_unit.reg_bank.registers[index]);
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
			32'h_0,					//$t0
			32'h_0,				//$t1
			32'h_0,				//$t2
			32'h_1,			//$t3
			32'h_0,			//$t4
			32'h_1, 					//$t5
			32'h_1,					//$t6
			32'h_0					//$t7
			);
		
		test_result_s(
			32'h_0,			//$s0
			32'h_0,			//$s1
			32'h_0,					//$s2
			32'h_0,			//$s3
			32'h_0,					//$s4
			32'h_0, 			//$s5
			32'h_0,					//$s6
			32'h_0					//$s7
			);	
	end
	
endmodule