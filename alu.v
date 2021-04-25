module alu (
				input [31:0] A, B, //Os operandos
				input [5:0] operation, 
				output reg [31:0] result
				);
	
	always @(*)
	begin
		case(operation)
			6'b100000: // Add
				// TODO: Testar overflow
				result <= A + B;
			6'b100001: // ADDU
				// OBSERVAÇÃO: O ADDU é simplesmente um add sem teste de overflow.
				result <= A + B;
			6'b100010: // Sub
				// TODO: Testar overflow
				result <= A - B;
			6'b100011: // SUBU
				// OBSERVAÇÃO: O SUBU é simplesmente um sub sem teste de overflow.
				result <= A - B;
			6'b100100: // And
				result <= A & B;
			6'b100101: // Or
				result <= A | B;
			6'b100111: // NOR
				result <= ~(A | B);
			6'b100110: // XOR
				result <= A ^ B;
			6'b000010: // MUL
				result <= A * B;
			default: result <= 32'd0;
		endcase
	end
	
endmodule