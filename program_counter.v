module program_counter(
	input	     clk, branch, alu_zero,
	input      [31:0] address,
	output	  [31:0] out
	);
   
	reg [31:0] pc;
	assign out = pc;
	
	initial
	begin
		pc = 0;
	end
	
   always @(posedge clk)
	begin
		pc = pc + 4;
		
		if (branch & alu_zero)
			begin
				pc = pc + (address << 2);
			end
    end
endmodule	// programCounter