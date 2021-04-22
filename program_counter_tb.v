`timescale 1ns / 1ps

module program_counter_tb;

	// Inputs
	reg clk, branch, alu_zero;
	reg [31:0] pc;
		
	wire [31:0] address, out;
	
	localparam period = 20;
	
	pc test_unit(
		.clk(clk), 
		.branch(branch),
		.alu_zero(alu_zero),
		.address(addre),
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
	
	always
	begin
		clk = 1'b1;
		#20;	// high for 20
		
		clk = 1'b0;
		#20;	// low for 20
	end
	
	always @(posedge clk)
	begin
		branch = 0;
		alu_zero = 0;
		#period;
		$display("PC: %0d\nOut: %0d\nAddress: %0d", pc, out, address);
		$display("Branch: %0d, Alu_zero: %0d", branch, alu_zero);
		test_result(32'd0);
	end
		
endmodule