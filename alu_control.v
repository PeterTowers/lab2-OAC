module alu_control(
		input[3:0] opALU,
		input[5:0] funct,
		output reg [4:0] operation
	);
	
	initial begin
		operation = 4'd15; 
	end
	
	always @ (*) begin
		case (opALU)			
			4'b0000:	// Load/Store word -> op: ADD
				operation <= 5'b00010;
			
			4'b0001:	// Branch BEQ -> op: SUB
				operation <= 5'b00110;
				
			4'b0010:	// Default AND
				operation <= 5'b00000;
			
			4'b0011:	// Default NOR
				operation <= 5'b01100;
			
			4'b0100:	// Default OR
				operation <= 5'b00001;
			
			4'b0101:	// Default XOR
				operation <= 5'b01101;
			
			4'b0110:	// Tipo-R -> op: funct
				case (funct)
					6'b10_0000:	// ADD
						operation <= 5'b00010;
					
					6'b10_0001:	// ADDU
						operation <= 5'b00011;
					
					6'b10_0100: // AND
						operation <= 5'b00000;
						
					6'b00_1011:	// MOVN
						operation <= 5'b00100;
					
					6'b10_0111:	// NOR
						operation <= 5'b01100;
					
					6'b10_0101: // OR
						operation <= 5'b00001;
						
					6'b00_0000:	// SLL
						operation <= 5'b00101;

					6'b10_1010: // SLT
						operation <= 5'b01001;
						
					6'b10_1011: // SLTU
						operation <= 5'b01010;
					
					/* TODO:
					6'b00_0011: // SRA
						operation <= 5'b00000;
					
					6'b00_0111: // SRAV
						operation <= 5'b00000;
					*/
					6'b00_0010: // SRL
						operation <= 5'b01011;
					

					6'b10_0010: // SUB
						operation <= 5'b00110;

					6'b10_0011: // SUBU
						operation <= 5'b00111;
					
					6'b10_0110: // XOR
						operation <= 5'b01101;
						
					default:
						operation <= 5'b00010;	// Soma
				endcase

			4'b0111:	// Branch BGEZ/BGEZAL
				operation <= 5'b01000; // Comparacao >= 0
				
			4'b1000:	// ADDU
				operation <= 5'b00011; //Soma sem overflow
				
			4'b1001: // LUI
				operation <= 5'b01111;
				
			4'b1010:	// SLTI
				operation <= 5'b01001;

			/* DEFAULT */
			default:
				operation <= 5'b11111;	// NO OP
		endcase	
	end	
endmodule