module byte_filter
	(
		input [31:0] in,
		input filter_enable,
		output reg [31:0] out
	); 
	
	always @*
	begin
		case(filter_enable)
			1'b0:	
				out <= in;
			1'b1: 
				out <= {24'h000000, in[7:0]};
		endcase
	end
	 
endmodule