module alu (
	input [31:0] A, B,			// Operandos
	input [3:0] operation, 		// Operacao
	input equal,					// Seletor para condicao de branch (igual ou desigual)
	output reg [31:0] result,	// Resultado
	output reg alu_zero			// Sinal de controle para branch
	);
	
	initial begin
		alu_zero = 0;
	end
	
	always @(*) begin
		alu_zero <= 0;
		
		case(operation)
			4'b0000:	// AND
				result <= A & B;
			
			4'b0001: // OR
				result <= A | B;
				
			4'b0010: // ADD
				// TODO: Testar overflow
				result <= A + B;
				
			4'b0011: // ADDU
				// OBSERVAÃ‡ÃƒO: O ADDU Ã© simplesmente um add sem teste de overflow.
				result <= A + B;
			
			/* SUB & BEQ/BNE */
			4'b0110: begin
				// TODO: Testar overflow
				result <= A - B;
				
				if (A == B)	// Para instrucao BEQ, result == 0 eh igualdade
					alu_zero <= 1'b1;
			end
			
			4'b0111: // SUBU
				// OBSERVAÃ‡ÃƒO: O SUBU Ã© simplesmente um sub sem teste de overflow.
				result <= A - B;
				
			/* BGEZ/BGEZAL */
			4'b1000: begin
				if (A >= 0)	begin		// BGEZ: branch se rs >= 0
					result <= 1;
					alu_zero <= 1'b1;
				end
				
				else begin				// Caso rs < 0, nao faz branch
					result <= 0;
					alu_zero <= 0;
				end
			end
			
			/* SLT */
			4'b1001: begin
				if (A < B)
					result = 1;
				else
					result = 0;
			end
				
			4'b1100: // NOR
				result <= ~(A | B);
				
			4'b1101: // XOR
				result <= A ^ B;
			/*	
			6'b000010: // MUL	-> MUL e DIV tem hardware especifico para eles
				result <= A * B;	// E o resultado de MUL pode ter 64 bits
			*/
			/* DEFAULT */
			default:	// Modifiquei para resultar em um valor "absurdo" (em decimal: 3.735.928.559; bin: 1101 1110 1010 1101 1011 1110 1110 1111)
				result <= 32'hdeadbeef;	// Assim a gente sabe que deu ruim nesse ponto

		endcase
		
		if (!equal)	// Caso para BNE
			alu_zero <= ~alu_zero;
		
	end
	
endmodule