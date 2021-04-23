module sign_extender_tb;

	reg [15:0] unextended; //MSB é o sinal
	wire [31:0] extended; 	
	sign_extender test_unit(
		.unextended(unextended), 
		.extended(extended)
	);
	
	initial begin
		unextended = 16'h000d; #100;
		$display("unextended: %b; extended: %b", unextended, extended);
		
		unextended = 16'hcccc; #100;
		$display("unextended: %b; extended: %b", unextended, extended);
	
	end
	
endmodule