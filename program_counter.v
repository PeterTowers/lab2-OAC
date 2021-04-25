module program_counter(						// clk comes from clock. branch and
	input	     clk, branch, alu_zero,	// alu_zero come from control unit.
	input      [31:0] address,	// Branch/jump address
	output	  [31:0] out		// Output bus
	);
   
	// PC (program counter) register.
	reg [31:0] pc;
	
	// Output is equal to PC.
	assign out = pc;
	
	// Starts PC at -1 so its first output value is zero.
	initial begin
		pc = -1;
	end

	/* PC is always incremented by 1. If there's a branch or jump, PC increases
	 * by 1 AND by the address times 4 (left logical shift by 2).
	 */
   always @(*) begin
		pc = pc + 1;
		
		if (branch & alu_zero)
			begin
				pc = pc + (address << 2);
			end
    end
endmodule	// programCounter