module sign_extender(
		input [15:0] unextended, //MSB é o sinal
		output reg [31:0] extended 
	);

	always@*
		begin 
			extended <= $signed(unextended);
		end
endmodule