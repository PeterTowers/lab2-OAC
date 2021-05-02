module alu (
	input [31:0] A, B,			// Operandos
	input [3:0] operation, 		// Operacao
	input [4:0] shamt,			// No. de deslocamentos binarios (shift amount)
	input equal,					// Seletor para condicao de branch (igual ou desigual)
	
	output reg [31:0] result,	// Resultado
	output reg alu_zero,			// Sinal de controle para branch
	output reg movn				// Sinal de controle para movn
	);
	
	initial begin
		alu_zero = 1'b0;
		movn = 1'b0;
	end
	
	always @(*) begin
		alu_zero <= 1'b0;
		movn <= 1'b0;
		result <= 32'hxxxxxxxx;
		
		case(operation)
			4'b0000:			// AND
				result <= A & B;
			
			4'b0001:			// OR
				result <= $signed(A) | $signed(B);
				
			4'b0010: 		// ADD
				// TODO: Testar overflow
				result <= $signed(A) + $signed(B);
				
			4'b0011: 		// ADDU
				result <= A + B;
				
			4'b0100:	begin	// MOVN
				if (B != 32'b0) begin	// Caso rt != 0
					result <= A;		// rd <- rs
					movn <= 1'b1;		// Habilita escrita no banco de registradores
				end

				else
					movn <= 1'b0;	// Caso contrario, nao permite escrita no bco reg
			end
			
			4'b0101:			// SLL
				result <= B << shamt;
			
			/* SUB & BEQ/BNE */
			4'b0110: begin
				// TODO: Testar overflow
				result <= $signed(A) - $signed(B);
				
				if ($signed(A) == $signed(B))	// Para instrucao BEQ, result == 0 eh igualdade
					if (equal)	
						alu_zero <= 1'b1;
					else // Caso para BNE
						alu_zero <= 1'b0;
				else
					if (equal)	
						alu_zero <= 1'b0;
					else // Caso para BNE
						alu_zero <= 1'b1;
			end
			
			4'b0111:			// SUBU				
				result <= A - B;
				
			/* BGEZ/BGEZAL */
			4'b1000: begin
				if ($signed(A) >= 0)	begin		// BGEZ: branch se rs >= 0
					result <= 1;
					alu_zero <= 1'b1;
				end
				
				else begin				// Caso rs < 0, nao faz branch
					result <= 0;
					alu_zero <= 0;
				end
			end
			
			/* SLT: Op. sinalizada (signed), sinal importa */
			4'b1001: begin
				if ($signed(A) < $signed(B))
					result <= 1;
				else
					result <= 0;
			end
			
			/* SLTU: Op. NAO sinalizada (unsigned), sinal n importa */
			4'b1010: begin
				if (A < B)
					result <= 1;
				else
					result <= 0;
			end
			
			4'b1011:			// SRL
				result <= B >> shamt;
				
			4'b1100:			// NOR
				result <= ~(A | B);
				
			4'b1101:			// XOR
				result <= A ^ B;
				
			4'b1111:			// LUI: B tem que ser os 16-bits superiores.
				result <= (B << 16);
			
			/* DEFAULT */
			default:	// Modifiquei para resultar em um valor "absurdo" (em decimal: 3.735.928.559; bin: 1101 1110 1010 1101 1011 1110 1110 1111)
				result <= 32'hdeadbeef;	// Assim a gente sabe que deu ruim nesse ponto

		endcase
		
		
		
	end
	
endmodule