/* 
 */
module muu_control(
		input[5:0] funct,
		output reg [3:0] operation,
		output reg muu_write_enable
	);
	
	initial begin
		muu_write_enable = 1'b0;	// Permite outras instrucoes escrever no bco
		operation = 4'b1111;
	end
	
	always @(*) begin
		muu_write_enable = 1'b0;	// Permite outras instrucoes escrever no bco
		
		case (funct)
			6'b000010: begin	// MUL - SPECIAL OP 011100; FUNCT 000010
				operation <= 4'b0000;
				muu_write_enable <= 1'b1;	// Escreve banco de registradores
			end
			
			6'b000000: begin	// MADD -SPECIAL OP 011100; FUNCT 000000
				operation <= 4'b0010;
				muu_write_enable <= 1'b0;	// NAO escreve banco de registradores
			end
			
			6'b000101: begin// MSUBU SPECIAL OP 011100; FUNCT 000101
				operation <= 4'b0011;
				muu_write_enable <= 1'b0;
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
				muu_write_enable <= 1'b0;	// NAO escreve banco de registradores
			end
				
			6'b011010: begin	// DIV
				operation <= 4'b0100;
				muu_write_enable <= 1'b0;	// NAO escreve banco de registradores
			end

			default:
				operation <= 4'b1111;		// NO OP
		endcase
	end
	
endmodule