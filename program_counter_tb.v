`timescale 1ns / 1ps

module program_counter_tb;

	// Inputs
	reg	clk, alu_zero;
	reg	[1:0]  pc_src;
	reg	[31:0] b_address, reg_addr;
	reg	[25:0] j_address;
	wire	[31:0] out;
	
	localparam period = 20;
	
	program_counter test_unit(
		.clk(clk), 
		.alu_zero(alu_zero),
		.pc_src(pc_src),
		.b_address(b_address),
		.j_address(j_address),
		.reg_addr(reg_addr),
		.out(out)
	);
	
	task test_result;
		input [31:0] expected_value;
		begin			
			if (out == expected_value) 
				$display("correct\n");
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
	 * PC should always increase by 1, except when branch AND alu_zero are equal
	 * to 1. In that case, PC = PC + address*4.
	 */
	initial begin
		alu_zero = 0;			// LO signal from ALU
		pc_src = 2'b11;		// pc_src = 2'b11 (src = PC+1)
		b_address = 32'bx;	// Doesn't matter
		j_address = 26'bx;	// Doesn't matter
		reg_addr = 32'bx;		// Doesn't matter
		#period;
		
		$display("Out: %0d\nBranch address: %0d", out, b_address);
		$display("Jump address: %0d\nJump reg. address: %0d", j_address, reg_addr);
		$display("pc_src: %2b, Alu_zero: %0d", pc_src, alu_zero);
		test_result(0);	// First instruction, starts at 0
		#period;
		
		alu_zero = 1;			// HI signal from ALU
		pc_src = 2'b11;		// But no branch signal from control
		b_address = 32'bx;	// Doesn't matter
		j_address = 26'bx;	// Doesn't matter
		reg_addr = 32'bx;		// Doesn't matter
		#period;
		
		$display("Out: %0d\nBranch address: %0d", out, b_address);
		$display("Jump address: %0d\nJump reg. address: %0d", j_address, reg_addr);
		$display("pc_src: %2b, Alu_zero: %0d", pc_src, alu_zero);
		test_result(1);	// Only alu_zero is set, so PC+1 = 1
		#period;
		
		alu_zero = 0;			// LO signal from ALU
		pc_src = 2'b00;		// pc_src indicates branch (2'b00)
		b_address = 32'bx;	// Doesn't matter
		j_address = 26'bx;	// Doesn't matter
		reg_addr = 32'bx;		// Doesn't matter
		#period;
		
		$display("Out: %0d\nBranch address: %0d", out, b_address);
		$display("Jump address: %0d\nJump reg. address: %0d", j_address, reg_addr);
		$display("pc_src: %2b, Alu_zero: %0d", pc_src, alu_zero);
		test_result(2);	// Branch is set, but not eq. or ineq. so PC+1 = 2
		#period;
		
		alu_zero = 1;				// HI signal from ALU (condition met)
		pc_src = 2'b00;			// pc_src indicates branch (2'b00)
		b_address = 32'b1010;	// Address for branch is set to 32'b1010 (d10)
		j_address = 26'bx;		// Doesn't matter
		reg_addr = 32'bx;			// Doesn't matter
		#period;
		
		$display("Out: %0d\nBranch address: %0d", out, b_address);
		$display("Jump address: %0d\nJump reg. address: %0d", j_address, reg_addr);
		$display("pc_src: %2b, Alu_zero: %0d", pc_src, alu_zero);
		test_result(43);	// Branch is set & condition is met, so PC = PC + address*4 = 43
		
		alu_zero = 0;				// LO signal from ALU
		pc_src = 2'b01;			// pc_src is set for jump (j/jal)
		b_address = 32'bx;		// Doesn't matter
		j_address = 26'b1111;	// Address for jump is set to 32'b1111 (d15)
		reg_addr = 32'bx;			// Doesn't matter
		#period;
		
		$display("Out: %0d\nBranch address: %0d", out, b_address);
		$display("Jump address: %0d\nJump reg. address: %0d", j_address, reg_addr);
		$display("pc_src: %2b, Alu_zero: %0d", pc_src, alu_zero);
		test_result(60);	// pc_src is set for jump, so PC = address*4 = 60
		
		alu_zero = 0;				// LO signal from ALU
		pc_src = 2'b10;			// pc_src is set for jr/jalr
		b_address = 32'bx;		// Doesn't matter
		j_address = 26'bx;		// Doesn't matter
		reg_addr = 32'b1101_1110_1010_1101_1011_1110_1110_1111; // Address set in register
		#period;
		
		$display("Out: %0d\nBranch address: %0d", out, b_address);
		$display("Jump address: %0d\nJump reg. address: %0d", j_address, reg_addr);
		$display("pc_src: %2b, Alu_zero: %0d", pc_src, alu_zero);
		test_result(32'hdeadbeef);	// pc_src is set for jr/jalr, so PC = reg_addr
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