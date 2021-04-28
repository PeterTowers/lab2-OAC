/*
Esse deve ser o conteudo do UnicicloInst.mif para estes testbench:

------------------------------------------------

DEPTH = 128;
WIDTH = 32;
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;
CONTENT
BEGIN

00000000 : 24180000; % 7: main:         la $t8, dados %
00000001 : 8f080000; % 8: lw $t0, 0($t8) %
00000002 : 8f090004; % 9: lw $t1, 4($t8) %
00000003 : 8f100008; % 10: lw $s0, 8($t8) %
00000004 : 0c000007; % 12: jal exemplo_folha %
00000005 : 00004020; % 14: add $t0, $0, $0 %
00000006 : 08000014; % 15: j exit %
00000007 : 23bdfff4; % 17: exemplo_folha:       addi $sp, $sp, -12      # cria espa?o para 3 itens na pilha %
00000008 : afa90008; % 18: sw $t1, 8($sp)       # empilha $t1 %
00000009 : afa80004; % 19: sw $t0, 4($sp)       # empilha $t2 %
0000000a : afb00000; % 20: sw $s0, 0($sp)       # empilha $s0 %
0000000b : 00854020; % 21: add $t0, $a0, $a1    # $t0 = g + h %
0000000c : 00c74820; % 22: add $t1, $a2, $a3    # $t1 = i + j %
0000000d : 01098022; % 23: sub $s0, $t0, $t1    # f = $s0 = (g+h) Ð (i+j) %
0000000e : 02001020; % 24: add $v0, $s0, $zero # retorna f em $v0 %
0000000f : 8fb00000; % 25: lw $s0, 0($sp)       # desempilha $s0 %
00000010 : 8fa80004; % 26: lw $t0, 4($sp)       # desempilha $t0 %
00000011 : 8fa90008; % 27: lw $t1, 8 ($sp)      # desempilha $t1 %
00000012 : 23bd000c; % 28: addi $sp, $sp, 12    # remove 3 itens da pilha %
00000013 : 03e00008; % 29: jr $ra               # retorna para a subrotina que chamou %     

END;
------------------------------------------------

Este tem que ser o conteúdo da memória de dados UnicicloData.mif:

------------------------------------------------
DEPTH = 128;
WIDTH = 32;
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;
CONTENT
BEGIN

00000000 : 00000001
00000001 : 00000002
00000002 : 00000003

END;


------------------------------------------------*/
`timescale 1ps / 1ps  
module mips_uniciclo_tb7;

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
			if (expected == mips_uniciclo_tb7.test_unit.reg_bank.registers[index])
				$display("$%0d: ok: %h", index, expected);
			else
				$display("$%0d: INCORRECT. Expected 0x%h; got 0x%h", index, expected, mips_uniciclo_tb7.test_unit.reg_bank.registers[index]);
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
			32'h_2,				//$t1
			32'h_0,				//$t2
			32'h_0,			//$t3
			32'h_0,			//$t4
			32'h_0, 					//$t5
			32'h_0,					//$t6
			32'h_0					//$t7
			);
		
		test_result_s(
			32'h_3,			//$s0
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