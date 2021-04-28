module sign_extender(
		input [15:0] unextended, //MSB é o sinal
		input signed_imm_extension,
		output reg [31:0] extended 
	);

	always@*
		begin 
			if (signed_imm_extension)
				extended <= $signed(unextended);
			else
				extended <= {16'h0000,unextended};
		end
endmodule