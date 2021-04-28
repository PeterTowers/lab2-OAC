module sign_extender_tb;

	reg [15:0] unextended; //MSB é o sinal
	reg signed_imm_extension;
	wire [31:0] extended; 	
	sign_extender test_unit(
		.unextended(unextended), 
		.signed_imm_extension(signed_imm_extension),
		.extended(extended)
	);
	
	initial begin
	
		signed_imm_extension = 1'b1;
		unextended = 16'h000d; #100;
		$display("unextended: %b; extended: %b", unextended, extended);
		
		unextended = 16'hcccc; #100;
		$display("unextended: %b; extended: %b", unextended, extended);
		
		signed_imm_extension = 1'b0; #100
		$display("unextended: %b; extended: %b", unextended, extended);
	
	end
	
endmodule