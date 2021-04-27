/* Esse deve ser o conteudo do UnicicloInst.mif para estes testbench

--------------------------------
DEPTH = 128;
WIDTH = 32;
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;
CONTENT
BEGIN

00000000 : 210802e6; % 2: addi $t0, $t0, 742 % 
00000001 : 31090529; % 3: andi $t1, $t0, 1321 %
00000002 : 01285020; % 4: add $t2, $t1, $t0 %  
00000003 : 01289023; % 5: subu $s2, $t1, $t0 % 
00000004 : 01285826; % 6: xor $t3, $t1, $t0 %  
00000005 : 01286022; % 7: sub $t4, $t1, $t0 %  
00000006 : 01286824; % 8: and $t5, $t1, $t0 %  
00000007 : 01287025; % 9: or $t6, $t1, $t0 %   
00000008 : 01287827; % 10: nor $t7, $t1, $t0 % 
00000009 : 01288026; % 11: xor $s0, $t1, $t0 % 
0000000a : 01288821; % 12: addu $s1, $t1, $t0 %

END;
------------------------------------------------*/

`timescale 1ps / 1ps  
module mips_uniciclo_tb2;

	reg pc_clock, inst_clock, data_clock, reg_clock;
	wire[31:0] ALUresult_out;
	
	mips_uniciclo test_unit(
		.pc_clock(pc_clock), 
		.inst_clock(inst_clock),
		.data_clock(data_clock),
		.reg_clock(reg_clock),
		.ALUresult_out(ALUresult_out)
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
			if (expected == mips_uniciclo_tb2.test_unit.reg_bank.registers[index])
				$display("$%0d: ok: %h", index, expected);
			else
				$display("$%0d: INCORRECT. Expected 0x%h; got 0x%h", index, expected, mips_uniciclo_tb2.test_unit.reg_bank.registers[index]);
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
			
		//for(i = 0; i <=31; i = i + 1) begin
		//	$display("Register[%0d] = 0x%h", i , mips_uniciclo_tb2.test_unit.reg_bank.registers[i]);
		//end
		//	
		
		test_result_t(
			32'h_2e6,
			32'h_20,
			32'h_306,
			32'h_2c6,
			32'h_fffffd3a,
			32'h_20, 
			32'h_2e6,
			32'h_fffffd19
			);
		
		test_result_s(
			32'h_2c6,
			32'h_306,
			32'h_fffffd3a,
			32'h_0,
			32'h_0,
			32'h_0, 
			32'h_0,
			32'h_0
			);
		
	end
	
endmodule