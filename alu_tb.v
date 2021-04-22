`timescale 1ns / 1ps  

module alu_tb;

	// Inputs
	reg [31:0] A, B;
	reg [5:0] operation;
	
	wire [31:0] out;
	
	alu test_unit(
		.A(A), 
		.B(B),
		.operation(operation),
		.out(out)
	);
	
	task test_result;
		input [31:0] expected_value;
		begin			
			if (out == expected_value) 
				$display("correct");
			else  
				$display("INCORRECT");
		end
	endtask
	
	initial begin
		A = 32'd6;
		B = 32'd4;
		
		operation = 6'b100000; #1
		$display("%0d + %0d = %0d", A, B, out);
		test_result(32'd10);
		
		operation = 6'b100010; #1
		$display("%0d - %0d = %0d", A, B, out);
		test_result(32'd2);
		
		operation = 6'b100100; #1
		$display("%b AND %b = %b", A, B, out);
		test_result(32'd4);
		
		operation = 6'b100101; #1
		$display("%b OR %b = %b", A, B, out);
		test_result(32'd6);
		
		operation = 6'b100111; #1
		$display("%b NOR %b = %b", A, B, out);
		test_result(32'b11111111111111111111111111111001);
		
		operation = 6'b100110; #1
		$display("%b XOR %b = %b", A, B, out);
		test_result(32'd2);
		
	end
endmodule