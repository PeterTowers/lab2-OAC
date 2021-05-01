/* Controle da unidade multiplicadora muu_control:
 * Recebe o campo funct da instrucao como entrada e determina a operacao a ser
 * executada na MUU, assim como se essa operacao escreve ou nao no banco de
 * registradores. Retorna o codigo da operacao a ser executada e uma flag que
 * permite ou nao a escrita no banco.
 */
module muu_control(
		input[5:0] funct,					// Campo FUNCT da instrucao
		
		output reg [3:0] operation,	// Codigo da op a ser executada na MUU
		output reg muu_write_enable	// Flag para permitir escrita no bco de reg
	);
	
	initial begin
		muu_write_enable = 1'b0;	// Desabilita escrita no banco
		operation = 4'b1111;			// Codigo p/ NO OP na MUU
	end
	
	always @(*) begin
		muu_write_enable = 1'b0;	// Desabilita escrita no banco
		
		case (funct)
			6'b000010: begin	// MUL
				operation <= 4'b0000;
				muu_write_enable <= 1'b1;	// Escreve banco de registradores
			end
			
			6'b000000: begin	// MADD
				operation <= 4'b0010;
				muu_write_enable <= 1'b0;	// Desabilita escrita no banco
			end
			
			6'b000101: begin// MSUBU
				operation <= 4'b0011;
				muu_write_enable <= 1'b0;	// Desabilita escrita no banco
			end
			
			6'b010000: begin	// MFHI
				operation <= 4'b0101;
				muu_write_enable <= 1'b1;	// Escreve banco de registradores
			end
				
			6'b010010: begin	// MFLO
				operation <= 4'b0110;
				muu_write_enable <= 1'b1;	// Escreve banco de registradores
			end
				
			6'b011000: begin	// MULT
				operation <= 4'b0001;
				muu_write_enable <= 1'b0;	// Desabilita escrita no banco
			end
				
			6'b011010: begin	// DIV
				operation <= 4'b0100;
				muu_write_enable <= 1'b0;	// Desabilita escrita no banco
			end

			/* DEFAULT */
			default:
				operation <= 4'b1111;		// NO OP
		endcase
	end
	
endmodule