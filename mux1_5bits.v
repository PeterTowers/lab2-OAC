module mux1_5bits
	(
		input [4:0] option_a,
		input [4:0] option_b,
		input [1:0] selector,
		output reg [4:0] out
	); 
	
	always @*
	begin
		case(selector)
			2'b00:	
				out <= option_a;
			2'b01: 
				out <= option_b;
			2'b10:
				out <= 5'd31;
		endcase
	end
	 
endmodule