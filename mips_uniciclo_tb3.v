/*
Esse deve ser o conteudo do UnicicloInst.mif para este testbench

--------------------------------
DEPTH = 128;
WIDTH = 32;
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;
CONTENT
BEGIN

00000000 : 20090064; % 3: addi $t1, $zero, 100 %
00000001 : 200a0064; % 4: addi $t2, $zero, 100 %
00000002 : 112a0001; % 5: beq $t1, $t2, errado1 %
00000003 : 114a0001; % 6: beq $t2, $t2, certo1 %
00000004 : 08000006; % 8: j fim1 %
00000005 : 216b0064; % 10: addi $t3, $t3, 100 %
00000006 : 15080001; % 12: bne $t0, $t0, errado2 %
00000007 : 150f0001; % 13: bne $t0, $t7, certo2 %
00000008 : 0800000a; % 15: j fim2 %
00000009 : 218c0064; % 17: addi $t4, $t4, 100 %
0000000a : 0800000b; % 19: j exit %
0000000b : 21ef0064; % 22: addi $t7, $t7, 100 %

END;
------------------------------------------------*/
`timescale 1ps / 1ps  
module mips_uniciclo_tb3;

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
			if (expected == mips_uniciclo_tb3.test_unit.reg_bank.registers[index])
				$display("$%0d: ok: %h", index, expected);
			else
				$display("$%0d: INCORRECT. Expected 0x%h; got 0x%h", index, expected, mips_uniciclo_tb3.test_unit.reg_bank.registers[index]);
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
			32'h_0, 	// $t0
			32'h_64,				// $t1
			32'h_64,				// $t2
			32'h_0,				// $t3
			32'h_0,				// $t4
			32'h_0, 				// $t5
			32'h_0,				// $t6
			32'h_64				// $t7
			);
		
//		test_result_s(
//			32'h_0,			//$s0
//			32'h_0,			//$s1
//			32'h_0,					//$s2
//			32'h_0,			//$s3
//			32'h_0,					//$s4
//			32'h_0, 			//$s5
//			32'h_0,					//$s6
//			32'h_0					//$s7
//			);	
	end
	
endmodule