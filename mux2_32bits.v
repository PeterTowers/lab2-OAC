module mux2_32bits
	(
		input [31:0] option_a,
		input [31:0] option_b,
		input [31:0] option_c,	// Return address (JAL/JALR/etc)
		input [1:0]  selector,
		output reg [31:0] out
	); 
	
	always @*
	begin
		case(selector)
			2'b00:	
				out <= option_a;
				
			2'b01: 
				out <= option_b;
				
			2'b10:
				out <= option_c;
		endcase
	end
	 
endmodule