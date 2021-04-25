module control_unit(
	input[0:5] opcode,				// OPCODE da instrucao
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
	
	always @(*)
	begin
		case(opcode)
/*----------------------------------------------------------------------------*/
			/* Instruções tipo R */
			6'b000000:
				begin
					reg_dst <= 1'd1; 				// Temos 3 registradores nesse caso
					jump <= 1'b0;					// NAO faz jump
					branch <= 1'b0;				// NAO faz branch
					mem_to_reg <= 1'b0;			// NAO escreve dado da memoria em reg
					opALU <= 4'd0;					// Operacaoo decidida pelo campo funct
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd0;				// 2o operando da ALU eh o 2o reg
					write_enable_reg <= 1'd1;	// Escreve no banco de registradores
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