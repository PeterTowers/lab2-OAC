`timescale 1ns / 1ps  

module muu_tb;
	// Inputs
	reg [31:0] rs, rt;
	reg [3:0] operation;	
	wire [31:0] result;
	wire div_zero;
	
	muu test_unit(
		.rs(rs), 
		.rt(rt),
		.operation(operation),
		.out(result),
		.div_zero(div_zero)
	);
	
	task test_result;
		input [31:0] expected_value;
		begin			
			if (result == expected_value) 
				$display("correct\n");
			else  begin
				$display("INCORRECT");
				$display("Expected: %h; Output: %h\n", expected_value, result);
			end
		end
	endtask
	
	initial begin
		rs = 32'd7;
		rt = 32'd2;
		operation = 4'b0000; #50	// MUL
		
		$display("%0h * %0h = %0h", rs, rt, result);
		test_result(32'd14);
		
		rs = 32'd7;
		rt = 32'hffff_fffe;
		operation = 4'b0000; #50	// MUL
		
		$display("%0h * %0h = %0h", rs, rt, result);
		test_result(32'hffff_fff2);
		
		rs = 32'h704D_0054;
		rt = 32'h400B_000C;
		operation = 4'b0001; #50	// MULT
		$display("%h * %h = %h; deve manter valor anterior", rs, rt, result);
		test_result(32'hffff_fff2);
		
		operation = 4'b0101; #50	//MFHI
		$display("HI = %h", result);
		test_result(32'h1C18_1369);
		
		operation = 4'b0110; #50	//MFLO
		$display("LO = %h", result);
		test_result(32'h4738_03F0);
		
		rs = 32'h704D_0054;
		rt = 32'h400B_000C;
		operation = 4'b0010; #1000	// MADD
		$display("%h * %h = %h; deve manter valor anterior", rs, rt, result);
		test_result(32'h4738_03F0);
		
		operation = 4'b0101; #50	//MFHI
		$display("HI = %h", result);
		test_result(32'h3830_26D2);
		
		operation = 4'b0110; #50	//MFLO
		$display("LO = %h", result);
		test_result(32'h8E70_07E0);
		
		
		
	end
endmodule