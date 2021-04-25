`timescale 1ns / 1ps

module program_counter_tb;

	// Inputs
	reg	clk, branch, alu_zero;	
	reg	[31:0] address;
	wire	[31:0] out;
	
	localparam period = 20;
	
	program_counter test_unit(
		.clk(clk), 
		.branch(branch),
		.alu_zero(alu_zero),
		.address(address),
		.out(out)
	);
	
	task test_result;
		input [31:0] expected_value;
		begin			
			if (out == expected_value) 
				$display("correct");
			else  
				$display("INCORRECT! Expected: %0d; Got: %0d", expected_value, out);
		end
	endtask
	
	always begin
		clk = 1'b1;
		#20;	// high for 20
		
		clk = 1'b0;
		#20;	// low for 20
	end

/*----------------------------------------------------------------------------*/
	/* Tests checking behaviour of PC when variables branch and alu_zero change.
	 * PC should always increase by 4, except when branch AND alu_zero are equal
	 * to 1. In that case, PC = PC + address*4.
	 */
	initial begin
		branch = 0;
		alu_zero = 0;
		address = 32'bx;
		#period;
		
		$display("Out: %0d\nAddress: %0d", out, address);
		$display("Branch: %0d, Alu_zero: %0d", branch, alu_zero);
		test_result(0);	// First instruction, starts at 0
		#period;
		
		branch = 0;
		alu_zero = 1;
		address = 32'bx;
		#period;
		
		$display("Out: %0d\nAddress: %0d", out, address);
		$display("Branch: %0d, Alu_zero: %0d", branch, alu_zero);
		test_result(4);	// Only alu_zero is set, so PC+4 = 4
		#period;
		
		branch = 1;
		alu_zero = 0;
		address = 32'bx;
		#period;
		
		$display("Out: %0d\nAddress: %0d", out, address);
		$display("Branch: %0d, Alu_zero: %0d", branch, alu_zero);
		test_result(8);	// Now, only branch is set, so PC+4 = 8
		#period;
		
		branch = 1;
		alu_zero = 1;
		address = 32'b1010;
		#period;
		
		$display("Out: %0d\nAddress: %0d", out, address);
		$display("Branch: %0d, Alu_zero: %0d", branch, alu_zero);
		test_result(52);	// Both variables are set, so PC = PC + address*4 = 52
	end
	
endmodule
/*----------------------------------------------------------------------------*/
	/*	Had some inconsistency using the for loop (variables would not be
	 * calculated correctly. Don't know if that's because of timing or because
	 * I'm a n00b, so, I'll leave this here for the time.
	 */
	/*
	integer i, ans;
	
	always @(*) begin
		for (i = 0; i < 40; i = i + 1) begin
			if (i < 10) begin
				branch = 0;
				alu_zero = 0;
				address = 32'bx;
				ans = i*4;
				#period;
				$display("Out: %0d\nAddress: %0d", out, address);
				$display("Branch: %0d, Alu_zero: %0d", branch, alu_zero);
				test_result(ans);
			end
			if (i < 20) begin
				branch = 1;
				alu_zero = 0;
				address = 32'bx;
				ans = i*4;
				#period;
				$display("Out: %0d\nAddress: %0d", out, address);
				$display("Branch: %0d, Alu_zero: %0d", branch, alu_zero);
				test_result(ans);
			end
			else if (i < 30) begin
				branch = 0;
				alu_zero = 1;
				address = 32'bx;
				ans = i*4;
				#period;
				$display("Out: %0d\nAddress: %0d", out, address);
				$display("Branch: %0d, Alu_zero: %0d", branch, alu_zero);
				test_result(i*4);
			end else begin
				branch = 1;
				alu_zero = 1;
				address = i*2 - 4;
				ans = out + i*2 - 4;
				#period;
				$display("Out: %0d\nAddress: %0d", out, address);
				$display("Branch: %0d, Alu_zero: %0d", branch, alu_zero);
				test_result(ans);
			end
			
			#period;
		end
		$stop;
	end
	*/