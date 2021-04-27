module alu_control(
		input[2:0] opALU,
		input[5:0] funct,
		output reg [3:0] operation
	);
	
	initial begin
		operation = 4'd15; 
	end
	
	always @ (*) begin
		case (opALU)			
			3'b000:	// Load/Store word -> op: ADD
				operation <= 4'b0010;
			
			3'b001:	// Branch BEQ -> op: SUB
				operation <= 4'b0110;
				
			3'b010:	// Default AND
				operation <= 4'b0000;
			
			3'b011:	// Default NOR
				operation <= 4'b1100;
			
			3'b100:	// Default OR
				operation <= 4'b0001;
			
			3'b101:	// Default XOR
				operation <= 4'b1101;
			
			3'b110:	// Tipo-R -> op: funct
				case (funct)
					6'b10_0000:	// ADD
						operation <= 4'b0010;
					
					6'b10_0001:	// ADDU
						operation <= 4'b0011;
					
					6'b10_0100: // AND
						operation <= 4'b0000;
					
					6'b10_0111:	// NOR
						operation <= 4'b1100;
					
					6'b10_0101: // OR
						operation <= 4'b0001;

					6'b10_1010: // SLT
						operation <= 4'b1001;
					
					/* TODO:
					6'b00_0011: // SRA
						operation <= 4'b0000;
					
					6'b00_0111: // SRAV
						operation <= 4'b0000;
					
					6'b00_0010: // SRL
						operation <= 4'b0000;
					*/

					6'b10_0010: // SUB
						operation <= 4'b0110;

					6'b10_0011: // SUBU
						operation <= 4'b0111;
					
					6'b10_0110: // XOR
						operation <= 4'b1101;
						
					default:
						operation <= 4'b0010;	// Soma
				endcase

			3'b111:	// Branch BGEZ/BGEZAL
				operation <= 4'b1000; // Comparacao >= 0

			default:	// Nao deve ocorrer
				operation <= 4'b0010;	// Soma
		endcase	
	end	
endmodule