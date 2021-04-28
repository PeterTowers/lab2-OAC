module mux2_32bits
	(
		input [31:0] option_a,
		input [31:0] option_b,
		input [31:0] option_c,
		input [31:0] option_d,
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
				
			2'b11:
				out <= option_d;
		endcase
	end
	 
endmodule