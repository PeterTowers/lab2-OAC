module alu (
	input [31:0] A, B,			// Operandos
	input [4:0] operation, 		// Operacao
	input [4:0] shamt,			// No. de deslocamentos binarios (shift amount)
	input equal,					// Seletor para condicao de branch (igual ou desigual)
	
	output reg [31:0] result,	// Resultado
	output reg alu_zero,			// Sinal de controle para branch
	output reg movn,				// Sinal de controle para movn
	output reg overflow			// Informa Overflow
	);
	
	initial begin
		alu_zero = 1'b0;
		movn = 1'b0;
	end
	
	always @(*) begin : update
		integer temp;
		
		alu_zero <= 1'b0;
		movn <= 1'b0;
		result <= 32'hxxxxxxxx;
		overflow <= 1'b0;
		
		case(operation)
			5'b00000:			// AND
				result <= A & B;
			
			4'b0001: // OR				
				result <= $signed(A) | $signed(B);
				
			4'b0010: begin	// ADD
				temp = $signed(A) + $signed(B);
				if (A[31] == 1'b1 && B[31] ==1'b1 && temp[31] != 1'b1) // Negativo + Negativo = Positivo
					overflow <= 1'b1;
				else if (A[31] == 1'b0 && B[31] ==1'b0 && temp[31] != 1'b0) // Positivo + Positivo = Negativo
					overflow <= 1'b1;
				else				
					result <= temp;
				
			end
				
			5'b00011: 		// ADDU
				result <= A + B;
				
			5'b00100:	begin	// MOVN
				if (B != 32'b0) begin	// Caso rt != 0
					result <= A;		// rd <- rs
					movn <= 1'b1;		// Habilita escrita no banco de registradores
				end

				else
					movn <= 1'b0;	// Caso contrario, nao permite escrita no bco reg
			end
			
			5'b00101:			// SLL
				result <= B << shamt;
			
			/* SUB & BEQ/BNE */
			4'b0110: begin
				temp = $signed(A) - $signed(B);
				
				if (A[31] == 1'b0 && B[31] == 1'b1 && temp[31] == 1'b1) begin // Positivo - Negativo = Negativo
					overflow <= 1'b1;
					$display("Overflow A");
				end else if (A[31] == 1'b0 && B[31] == 1'b1 && temp[31] == 1'b0) begin // Negativo - Positivo = Positivo
					overflow <= 1'b1;
					$display("Overflow B");				
				end else				
					result <= temp;
				
				
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
			
			5'b00111:			// SUBU				
				result <= A - B;
				
			/* BGEZ/BGEZAL */
			5'b01000: begin
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
			5'b01001: begin
				if ($signed(A) < $signed(B))
					result <= 1;
				else
					result <= 0;
			end
			
			/* SLTU: Op. NAO sinalizada (unsigned), sinal n importa */
			5'b01010: begin
				if (A < B)
					result <= 1;
				else
					result <= 0;
			end
			
			5'b01011:			// SRL
				result <= B >> shamt;
				
			5'b01100:			// NOR
				result <= ~(A | B);
				
			5'b01101:			// XOR
				result <= A ^ B;
				
			5'b01110:			// SRA
				result <= $signed(B) >>> shamt;
				
			5'b01111:			// LUI: B tem que ser os 16-bits superiores.
				result <= (B << 16);
				
			5'b10000:			// SRAV
				result <= $signed(B) >>> A[4:0];
			
			/* DEFAULT */
			default:
				;	// NO OP
		endcase
		
		
		
	end
	
endmodule