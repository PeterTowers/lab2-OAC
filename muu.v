/* Unidade multiplicadora (MUU - MUltiplication Unit):
 *	Realiza operacoes relacionadas a multiplicacao e divisao. Guarda os
 * resultados nos registradores 'hi' e 'lo', que devem ser resgatados posterior-
 * mente, dependendo da operacao.
 */
/*----------------------------------------------------------------------------*/
module muu (
	input clk,					// Clock
	input [31:0] rs, rt,		// Operandos
	input [3:0] operation,	// Operacao - pode ser reduzido p/ 3 bits,
									// deixando 4 para eventual expansao
	output reg div_zero,		// Indica divisao por zero
	output reg [31:0] out,	// Saida dos dados
	output reg [31:0] hi, lo // Expoe os valores de hi e lo p/ apresentar&debugar
	);
	
	reg [63:0] result;
	
	
	initial begin
		hi <= 0;
		lo <= 0;
		out <= 0;
		div_zero <= 0;
	
	end
	
	always @(posedge clk) begin
		div_zero <= 0;
		
		case(operation)
			4'b0000: begin	// MUL
				result = $signed(rs) * $signed(rt);
				out <= result[31:0];
				hi <= result[63:32];
				lo <= result[31:0];
			end
			
			4'b0001: begin	// MULT
				result = $signed(rs) * $signed(rt);
				hi <= result[63:32];
				lo <= result[31:0];
			end
			
			4'b0010: begin	// MADD
				result = $signed(rs) * $signed(rt);
				result = result + {hi, lo};
				
				hi <= result[63:32];
				lo <= result[31:0];
			end
			
			4'b0011: begin	// MSUBU: multip., neste caso, desconsidera sinal
				result = rs * rt;
				hi <= hi - result[63:32];
				lo <= lo - result[31:0];
			end
			
			4'b0100: begin // DIV
				if (rt != 0) begin
					lo <= $signed(rs) / $signed(rt);
					hi <= $signed(rs) % $signed(rt);
				end
				
				else
					div_zero <= 1'b1;
			end
			
			4'b0101:	// MFHI
				out <= hi;
			
			4'b0110:	// MFLO
				out <= lo;
			
			default:	// NO OP
				;
		endcase
	end
	
endmodule