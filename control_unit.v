module control_unit(
	input[0:5] opcode, funct,		// Campos "opcode" e "funct"
	output reg reg_dst, 				// Escolhe o reg em que sera salvo P/ instrucao
											// com 2 é 0, p/ 3, é 1.
	output reg jump,					// P/ instrucoes de JUMP. 1 indica jump
	output reg branch,				// P/ instrucoes de BRANCH. 1 indica branch
	output reg mem_to_reg,			// Escrita da memoria de dados no banco de reg
	output reg[3:0] opALU,			// Operacao a ser executada na ALU
	output reg write_enable_mem,	// Habilita escrita na memoria de dados
	output reg origALU,				// Origem do 2o operando da ALU
	output reg write_enable_reg	// Habilita escrita no banco de registradores
	);

	// Condicoes iniciais setadas como todos sinais iguais a zero
	initial begin
		reg_dst = 1'b0;
		jump = 1'b0;
		branch = 1'b0;
		mem_to_reg = 1'b0;
		opALU = 4'b0;
		write_enable_mem = 1'b0;
		origALU = 1'b0;
		write_enable_reg = 1'b0;
	end	
	
	always @(*) begin
		case(opcode)
/*----------------------------------------------------------------------------*/
			/* Instruções tipo R */
			6'b000000: begin
				reg_dst <= 1'd1; 				// Temos 3 registradores nesse caso
				mem_to_reg <= 1'b0;			// NAO escreve dado da memoria em reg
				write_enable_mem <= 1'b0;	// NAO escreve na memoria
				origALU <= 1'd0;				// 2o operando da ALU eh o 2o reg
					
				case (funct)
					6'b10_0000: begin	// ADD
						jump <= 1'b0;					// NAO faz jump
						branch <= 1'b0;				// NAO faz branch
						opALU <= 4'b1;					// Operacao de soma na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b10_0001: begin	// ADDU
						jump <= 1'b0;					// NAO faz jump
						branch <= 1'b0;				// NAO faz branch
						opALU <= 4'b1;					// Operacao de soma na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b10_0100: begin	// AND
						jump <= 1'b0;					// NAO faz jump
						branch <= 1'b0;				// NAO faz branch
						opALU <= 4'b11;				// Operacao AND na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					/* TODO:
					6'b01_1010: begin	// DIV
						jump <= 1'b0;					// NAO faz jump
						branch <= 1'b0;				// NAO faz branch
						opALU <= 4'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					*/
					
					6'b00_1001: begin	// JALR
						jump <= 1'b1;					// Faz jump
						branch <= 1'b0;				// NAO faz branch
						opALU <= 4'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b00_1000: begin	// JR
						jump <= 1'b1;					// Faz jump
						branch <= 1'b0;				// NAO faz branch
						opALU <= 4'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b0;	// NAO escreve no banco de reg
					end
					
					/* TODO:
					6'b01_0000: begin	// MFHI
						jump <= 1'b0;					// NAO faz jump
						branch <= 1'b0;				// NAO faz branch
						opALU <= 4'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b01_0010: begin	// MFLO
						jump <= 1'b0;					// NAO faz jump
						branch <= 1'b0;				// NAO faz branch
						opALU <= 4'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					*/
					
					6'b10_0111: begin	// NOR
						jump <= 1'b0;					// NAO faz jump
						branch <= 1'b0;				// NAO faz branch
						opALU <= 4'b0;					// Operacao NOR na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b10_0101: begin	// OR
						jump <= 1'b0;					// NAO faz jump
						branch <= 1'b0;				// NAO faz branch
						opALU <= 4'b100;				// Operacao OR na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					/* TODO:
					6'b00_0000: begin	// SLL
						jump <= 1'b0;					// NAO faz jump
						branch <= 1'b0;				// NAO faz branch
						opALU <= 4'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b10_1010: begin	// SLT
						jump <= 1'b0;					// NAO faz jump
						branch <= 1'b0;				// NAO faz branch
						opALU <= 4'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b00_0011: begin	// SRA
						jump <= 1'b0;					// NAO faz jump
						branch <= 1'b0;				// NAO faz branch
						opALU <= 4'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b00_0111: begin	// SRAV
						jump <= 1'b0;					// NAO faz jump
						branch <= 1'b0;				// NAO faz branch
						opALU <= 4'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b00_0010: begin	// SRL
						jump <= 1'b0;					// NAO faz jump
						branch <= 1'b0;				// NAO faz branch
						opALU <= 4'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					*/
					
					6'b10_0010: begin	// SUB
						jump <= 1'b0;					// NAO faz jump
						branch <= 1'b0;				// NAO faz branch
						opALU <= 4'b0;					// Operacao de subtracao na ALU - TODO: colocar valor da operacao na atribuicao da variavel
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end

					6'b10_0011: begin	// SUBU
						jump <= 1'b0;					// NAO faz jump
						branch <= 1'b0;				// NAO faz branch
						opALU <= 4'b0;					// Operacao de subtracao na ALU - TODO: colocar valor da operacao na atribuicao da variavel
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b10_0110: begin	// XOR
						jump <= 1'b0;					// NAO faz jump
						branch <= 1'b0;				// NAO faz branch
						opALU <= 4'b101;				// Operacao XOR na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
				endcase
			end

/*----------------------------------------------------------------------------*/
			/* Instruções tipo I */				
			6'b001000:  //ADDI
				begin
					reg_dst <= 1'b0;				// Apenas 2 registradores nesse caso
					jump <= 1'b0;					//	NAO faz jump
					branch <= 1'b0;				// NAO faz branch
					mem_to_reg <= 1'b0;			// NAO escreve dado da memoria em reg
					opALU <= 4'd1;					// Operação de soma na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1; 				// 2o operando da ALU eh o imediato
					write_enable_reg <= 1'd1;	// Escreve no banco de registradores
				end
				
			6'b001100:  //ANDI //TODO: No manual do MIPS diz que a extensão de sinal no ANDI é sempre de zeros, porém, na forma atual está extensão sinalizada.
				begin 
					reg_dst <= 1'd0;				// Apenas 2 registradores nesse caso
					jump <= 1'b0;					//	NAO faz jump
					branch <= 1'b0;				// NAO faz branch
					mem_to_reg <= 1'b0;			// NAO escreve dado da memoria em reg
					opALU <= 4'd3;					// Operacao AND na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh o imediato
					write_enable_reg <= 1'd1;	// Escreve no banco de registradores
				end
				
			6'b001101:  //ORI //TODO: No manual do MIPS diz que a extensão de sinal no ANDI é sempre de zeros, porém, na forma atual está extensã sinalizada.
				begin 
					reg_dst <= 1'd0;				// Apenas 2 registradores nesse caso
					jump <= 1'b0;					//	NAO faz jump
					branch <= 1'b0;				// NAO faz branch
					mem_to_reg <= 1'b0;			// NAO escreve dado da memoria em reg
					opALU <= 4'd4;					// Operacao OR na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh o imediato
					write_enable_reg <= 1'd1;	// Escreve no banco de registradores
				end
				
			6'b001110:  //XORI //TODO: No manual do MIPS diz que a extensão de sinal no ANDI é sempre de zeros, porém, na forma atual está extensã sinalizada.
				begin 
					reg_dst <= 1'd0;				// Apenas 2 registradores nesse caso
					jump <= 1'b0;					//	NAO faz jump
					branch <= 1'b0;				// NAO faz branch
					mem_to_reg <= 1'b0;			// NAO escreve dado da memoria em reg
					opALU <= 4'd5;					// Operacao XOR na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh o imediato
					write_enable_reg <= 1'd1;	// Escreve no banco de registradores
				end
			
			6'b101011:  //SW
				begin
					reg_dst <= 1'd0;				// Apenas 2 registradores nesse caso
					jump <= 1'b0;					//	NAO faz jump
					branch <= 1'b0;				// NAO faz branch
					mem_to_reg <= 1'b0;			// NAO escreve dado da memoria em reg
					opALU <= 4'd1;					// Operacao de soma na ALU
					write_enable_mem <= 1'b1;	// Escreve na memória
					origALU <= 1'd1;				// 2o operando da ALU eh imediato/offset
					write_enable_reg <= 1'd0;	// NAO escreve registrador
				end
				
			6'b100011:  //LW
				begin
					reg_dst <= 1'b0;				// Apenas 2 registradores nesse caso
					jump <= 1'b0;					//	NAO faz jump
					branch <= 1'b0;				// NAO faz branch
					mem_to_reg <= 1'b1;			// NAO escreve dado da memoria em reg
					opALU <= 4'd1;					// Operacao de soma na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memória
					origALU <= 1'd1;				// 2o operando da ALU eh imediato/offset
					write_enable_reg <= 1'd1;	// Escreve no banco de registradores
				end
			
			6'b011100:  //MUL - SPECIAL2
				begin
					reg_dst <= 1'd1; 				// Temos 3 registradores nesse caso
					jump <= 1'b0;					//	NAO faz jump
					branch <= 1'b0;				// NAO faz branch
					mem_to_reg <= 1'b0;			// NAO escreve dado da memoria em reg
					opALU <= 4'd0;					// Operacao decidida pelo campo funct
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd0;				// 2o operando da ALU eh o 2o reg
					write_enable_reg <= 1'd1;	// Escreve no banco de registradores
				end
				
/*----------------------------------------------------------------------------*/
			/* Instruções tipo J */
			6'b000010:	// J (jump)
				begin
					reg_dst <= 1'bx; 				// Nao escreve bco reg, nao importa
					jump <= 1'b1;					// Instrucao de jump
					branch <= 1'b0;				// NAO faz branch
					mem_to_reg <= 1'bx; 			// Nao escreve, nao importa
					opALU <= 4'bx; 				// Nao usa ALU, nao importa
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'bx; 				// Nao usa ALU, nao importa
					write_enable_reg <= 1'b0;	// NAO escreve registrador
				end
				
			6'b000011:	// JAL (jump and link) TODO
				begin
					reg_dst <= 1'bx; 				// Nao escreve bco reg, nao importa
					jump <= 1'b1;					// Instrucao de jump
					branch <= 1'b0;				// NAO faz branch
					mem_to_reg <= 1'bx; 			// Nao escreve, nao importa
					opALU <= 4'bx; 				// Nao usa ALU, nao importa
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'bx; 				// Nao usa ALU, nao importa
					write_enable_reg <= 1'b0;	// NAO escreve registrador
				end
				
/*----------------------------------------------------------------------------*/
			/* DEFAULT */
			default:
				begin
					reg_dst <= 1'b0;
					jump <= 1'b0;
					branch <= 1'b0;
					mem_to_reg <= 1'b0;
					opALU <= 4'b0; 
					write_enable_reg <= 1'b0;
					origALU <= 1'b0;
					write_enable_mem <= 1'b0; 					
				end				
		endcase
	end
	
endmodule