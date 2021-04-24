module alu_control(
		input[3:0] opALU,
		input[5:0] funct,
		output reg [5:0] operation
	);
	
	initial
	begin
		operation = 6'd0; 
	end
	
	always @ *
	begin
		case (opALU)			
			4'd0:
				operation <= funct; // O próprio funct será o código da ULA. 
			4'd1: 
				operation <= 6'b100000; // Soma
			4'd2:
				operation <= 6'b100010; // Subtração
			4'd3:
				operation <= 6'b100100; // And
			4'd4:
				operation <= 6'b100101; // Or
			4'd5:
				operation <= 6'b100110; // Xor
			
			
		endcase
	
	end
	
	
endmodule
	
	