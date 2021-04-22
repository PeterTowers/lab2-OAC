module programCounter (
	input	     clk, branch, alu_zero,
	input		  [31:0] address,
	output	  [31:0] out
	);
   
	reg [31:0] pc;
	assign out = pc;
	
   always @ (posedge clk)
	begin
		pc = pc + 4;
		
		if (branch & alu_zero)
			begin
				address = address<<2;
				pc = pc + address;
			end
    end
endmodule	// programCounter