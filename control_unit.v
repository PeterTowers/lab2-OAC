module control_unit(
	input[0:5] opcode, funct,			// Campos "opcode" e "funct"
	input[4:0] rt,							// Registrador rt p/ instrucoes BGEZ/BGEZAL
	
	output reg [1:0] pc_src,			// Determina a escolha do proximo PC
	output reg [1:0] reg_dst, 			// Escolhe o reg em que sera salvo P/ instrucao
												// com 2 eh 0, p/ 3, eh 1, PC eh 2.
	output reg [1:0] reg_write,		// Escolhe qual dado sera salvo no bco de reg
												// 00 eh reg, 01 mem, 10 return address, 11 MUU
	output reg [3:0] opALU,				// Operacao a ser executada na ALU
	output reg write_enable_mem,		// Habilita escrita na memoria de dados
	output reg origALU,					// Origem do 2o operando da ALU
	output reg [1:0] write_enable_reg,	// Habilita escrita no banco de registradores
	output reg equal,						// Condicao de escolha entre resultado BEQ/BNE
	output reg signed_imm_extension,	// Decide se a extensao de sinal do imediato sera sinalizada ou nao
	output reg mem_byte_mode			// Decide se a leitura e escrita na memoria vao ser em Byte (1), ou Word (0)
	);

	// Definicao das condicoes iniciais
	initial begin
		reg_dst = 2'b0;
		pc_src = 2'b11;				// Indica saida simples (PC+1)
		reg_write = 2'b00;
		opALU = 4'b0;
		write_enable_mem = 1'b0;
		origALU = 1'b0;
		write_enable_reg = 2'b00;
		equal = 1'b1;
		signed_imm_extension = 1'b1;
	end	
	
	always @(*) begin
		equal <= 1'bx;
		reg_write <= 2'bxx;
		case(opcode)
/*----------------------------------------------------------------------------*/
			/* Instrucoes tipo R */
			6'b000000: begin					
				case (funct)
					6'b00_1001: begin	// JALR
						reg_dst <= 2'd2;				// Instrucao salva pc+1 em $ra
						pc_src = 2'b10;				// PC = rs
						reg_write <= 2'b00;			// Escreve return address no banco
						opALU <= 4'bx;					// Nao usa ALU, nao importa
						write_enable_mem <= 1'b0;	// NAO escreve na memoria
						origALU <= 1'd0;				// 2o operando da ALU eh o 2o reg
						write_enable_reg <= 2'b01;	// Escreve no banco de reg
						signed_imm_extension <= 1'bx; //Don't care imediato
						mem_byte_mode <= 1'bx;		// Don't care sobre uso da memoria
					end
					
					6'b00_1000: begin	// JR
						reg_dst <= 2'd1;				// Temos 3 registradores nesse caso
						pc_src = 2'b10;				// PC = rs
						reg_write <= 2'bx;			// Nao escreve bco reg, nao importa
						opALU <= 4'bx;					// Nao usa ALU, nao importa
						write_enable_mem <= 1'b0;	// NAO escreve na memoria
						origALU <= 1'd0;				// 2o operando da ALU eh o 2o reg
						write_enable_reg <= 2'b00;	// NAO escreve no banco de reg
						signed_imm_extension <= 1'bx; //Don't care imediato
						mem_byte_mode <= 1'bx;		// Don't care sobre uso da memoria
					end
					
					/* DEFAULT */
					default: begin
						reg_dst <= 2'd1;				// Temos 3 registradores nesse caso
						pc_src <= 2'b11;				// PC = PC+1 (nao faz branch ou jump)
						
						opALU <= 4'b110;				// Avaliar campo funct na alu_control
						write_enable_mem <= 1'b0;	// NAO escreve na memoria
						origALU <= 1'd0;				// 2o operando da ALU eh o 2o reg
						write_enable_reg <= 2'b01;	// Escreve no banco de reg
						signed_imm_extension <= 1'bx; //Don't care imediato
						mem_byte_mode <= 1'bx;		// Don't care sobre uso da memoria
						
						if (funct < 6'b100000) 		// Operacoes na MUU
							reg_write <= 2'b11;		// Escreve resultado da MUU no banco
							
						else if (funct == 6'b001011)	//MOVN
							write_enable_reg <= 2'b10;	// Escrita no bco reg condicional
							
						else								// Operacoes na ALU
							reg_write <= 2'b00;		// Escreve resultado da ALU no banco
					end
					
					/* TODO:
					
					6'b00_0000: begin	// SLL
						pc_src = 2'b11;				// PC = PC+1
						opALU <= 4'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b00_0011: begin	// SRA
						pc_src = 2'b11;				// PC = PC+1
						opALU <= 4'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b00_0111: begin	// SRAV
						pc_src = 2'b11;				// PC = PC+1
						opALU <= 4'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b00_0010: begin	// SRL
						pc_src = 2'b11;				// PC = PC+1
						opALU <= 4'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					*/
				endcase
			end
			
			/* Instrucoes tipo SPECIAL - semelhantes a tipo-R */	
				
			6'b011100:  //MUL, MADD, MSUBU
				begin
					reg_dst <= 2'd1;				// Temos 3 registradores nesse caso
					pc_src = 2'b11;				// PC = PC+1
					reg_write <= 2'b11;			// Escreve resultado da MUU no banco
					opALU <= 4'dx;					// NAO opera na ALU, nao importa
					write_enable_mem <= 1'b1;	// NAO escreve na memoria
					origALU <= 1'd0;				// 2o operando da ALU eh o 2o reg
					write_enable_reg <= 2'b10;	// Escreve no banco de registradores
					signed_imm_extension <= 1'bx; //Don't care imediato
					mem_byte_mode <= 1'bx;		// Don't care sobre uso da memoria
				end

/*----------------------------------------------------------------------------*/
			/* Instrucoes tipo I */				
			6'b001000:  //ADDI
				begin
					reg_dst <= 2'd0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b11;				// PC = PC+1
					reg_write <= 2'b00;			// Escreve resultado da ALU no banco
					opALU <= 4'b000;				// Operacao de soma na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1; 				// 2o operando da ALU eh o imediato
					write_enable_reg <= 2'b01;	// Escreve no banco de registradores
					signed_imm_extension <= 1'b1; //Imediato com extensao sinalizada
					mem_byte_mode <= 1'bx;		// Don't care sobre uso da memoria
				end
			6'b001001:  //ADDIU
				begin
					reg_dst <= 2'd0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b11;				// PC = PC+1
					reg_write <= 2'b00;			// Escreve resultado da ALU no banco
					opALU <= 4'b000;				// Operacao de ADDU na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1; 				// 2o operando da ALU eh o imediato
					write_enable_reg <= 2'b01;	// Escreve no banco de registradores
					signed_imm_extension <= 1'b1; //Imediato com extensao sinalizada
					mem_byte_mode <= 1'bx;		// Don't care sobre uso da memoria
				end
				
			6'b001100:  //ANDI 
				begin 
					reg_dst <= 2'd0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b11;				// PC = PC+1
					reg_write <= 2'b00;			// Escreve resultado da ALU no banco
					opALU <= 4'b010;				// Operacao AND na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh o imediato
					write_enable_reg <= 2'b01;	// Escreve no banco de registradores
					signed_imm_extension <= 1'b0; //Imediato com extensao NAO-inalizada
					mem_byte_mode <= 1'bx;		// Don't care sobre uso da memoria
				end
				
			6'b000100:	// BEQ
				begin
					reg_dst <= 2'd0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b00;				// Branch
					reg_write <= 2'bx;			// Nao escreve no bco, nao importa
					opALU <= 4'b001;				// Operacao de subtracao na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd0;				// 2o operando da ALU eh o registrador 2
					write_enable_reg <= 2'b00;	// NAO escreve no bco de registradores
					equal <= 1'b1;					// Testa igualdade na ALU
					signed_imm_extension <= 1'b1; //imediato sinalizado
					mem_byte_mode <= 1'bx;		// Don't care sobre uso da memoria
				end
			
			6'b000001:	// "REGIMM" - BGEZ/BGEZAL
				begin
					pc_src = 2'b00;				// Branch
					reg_write <= 2'b10;			// Qnd escreve bco, escreve return address
					opALU <= 4'b0111;				// Operacao de especial na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh o imediato
					equal <= 1'b1;					// Testa igualdade na ALU
					signed_imm_extension <= 1'b1; //imediato sinalizado
					mem_byte_mode <= 1'bx;		// Don't care sobre uso da memoria
					
					
					if (rt == 5'b00001) begin	// BEGEZ
						reg_dst <= 2'd0;				// Apenas 2 registradores nesse caso
						write_enable_reg <= 2'b00;	// NAO escreve no bco de registradores
					end
					
					else begin						// BGEZAL
						reg_dst <= 2'd2;				// Instrucao salva pc+1 em $ra
						write_enable_reg <= 2'b01;	// Escreve no banco de registradores
					end
				end
			
			6'b000101:	// BNE
				begin
					reg_dst <= 2'd0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b00;				// Branch
					reg_write <= 2'bx;			// Nao escreve no bco, nao importa
					opALU <= 4'b0001;				// Operacao de subtracao na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd0;				// 2o operando da ALU eh o 2o registrador
					write_enable_reg <= 2'b00;	// NAO escreve no bco de registradores
					equal <= 1'b0;					// Testa desigualdade na ALU
					signed_imm_extension <= 1'b1; //imediato sinalizado
					mem_byte_mode <= 1'bx;		// Don't care sobre uso da memoria
				end
				
			6'b100011:  //LW
				begin
					reg_dst <= 2'b0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b11;				// PC = PC+1
					reg_write <= 2'b01;			// Escreve dado da memoria no bco de reg
					opALU <= 4'b000;				// Operacao de soma na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh imediato/offset
					write_enable_reg <= 2'b01;	// Escreve no banco de registradores
					signed_imm_extension <= 1'b1; //Imediato com extensao sinalizada
					mem_byte_mode <= 1'b0;		// Memoria em Word mode.
				end
			
			6'b100000:  //LB
				begin
					reg_dst <= 2'b0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b11;				// PC = PC+1
					reg_write <= 2'b01;			// Escreve dado da memoria no bco de reg
					opALU <= 4'b000;				// Operacao de soma na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh imediato/offset
					write_enable_reg <= 2'b01;	// Escreve no banco de registradores
					signed_imm_extension <= 1'b1; //Imediato com extensao sinalizada
					mem_byte_mode <= 1'b1;		// Memoria em Byte mode.
				end
				
			6'b001101:  //ORI 
				begin 
					reg_dst <= 2'd0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b11;				// PC = PC+1
					reg_write <= 2'b00;			// Escreve resultado da ALU no banco
					opALU <= 4'b0100;				// Operacao OR na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh o imediato
					write_enable_reg <= 2'b01;	// Escreve no banco de registradores
					signed_imm_extension <= 1'b0; //Imediato com extensao NAO sinalizada
					mem_byte_mode <= 1'bx;		// Don't care sobre uso da memoria
				end
			
			6'b001111:  //LUI
				begin 
					reg_dst <= 2'd0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b11;				// PC = PC+1
					reg_write <= 2'b00;			// Escreve resultado da ALU no banco
					opALU <= 4'b1001;				// Operacao LUI na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh o imediato
					write_enable_reg <= 2'b01;	// Escreve no banco de registradores
					signed_imm_extension <= 1'b0; //Imediato com extensao NAO sinalizada
					mem_byte_mode <= 1'bx;		// Don't care sobre uso da memoria
				end
			
			6'b101011:  //SW
				begin
					reg_dst <= 2'd0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b11;				// PC = PC+1
					reg_write <= 2'bx;			// Nao escreve no bco, nao importa
					opALU <= 4'b000;				// Operacao de soma na ALU
					write_enable_mem <= 1'b1;	// Escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh imediato/offset
					write_enable_reg <= 2'b00;	// NAO escreve registrador
					signed_imm_extension <= 1'b1; //Imediato com extensao sinalizada
					mem_byte_mode <= 1'b0;		// Memoria em word mode.
				end
			6'b101000:  //SB
				begin
					reg_dst <= 2'd0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b11;				// PC = PC+1
					reg_write <= 2'bx;			// Nao escreve no bco, nao importa
					opALU <= 4'b000;				// Operacao de soma na ALU
					write_enable_mem <= 1'b1;	// Escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh imediato/offset
					write_enable_reg <= 2'b00;	// NAO escreve registrador
					signed_imm_extension <= 1'b1; //Imediato com extensao sinalizada
					mem_byte_mode <= 1'b1;		// Memoria em byte mode.
				end
				
			
			
			6'b001110:  //XORI 
				begin 
					reg_dst <= 2'd0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b11;				// PC = PC+1
					reg_write <= 2'b00;			// Escreve resultado da ALU no banco
					opALU <= 4'b101;				// Operacao XOR na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh o imediato
					write_enable_reg <= 2'b01;	// Escreve no banco de registradores
					signed_imm_extension <= 1'b0; //Imediato com extensao NAO sinalizada
					mem_byte_mode <= 1'bx;		// Don't care sobre uso da memoria
				end
				
/*----------------------------------------------------------------------------*/
			/* Instrucoes tipo J */
			6'b000010:	// J (jump)
				begin
					reg_dst <= 2'bx;				// Nao escreve bco reg, nao importa
					pc_src = 2'b01;				// Jump incondicional
					reg_write <= 2'bx;			// Nao escreve no bco, nao importa
					opALU <= 4'bx;					// Nao usa ALU, nao importa
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'bx; 				// Nao usa ALU, nao importa
					write_enable_reg <= 2'b00;	// NAO escreve registrador
					signed_imm_extension <= 1'b0; //Imediato com extensao NAO sinalizada
					mem_byte_mode <= 1'bx;		// Don't care sobre uso da memoria
				end
				
			6'b000011:	// JAL (jump and link)	TODO
				begin
					reg_dst <= 2'd2; 				// Instrucao salva pc+1 em $ra
					pc_src = 2'b01;				// Jump incondicional
					reg_write <= 2'b10;			// Escreve return address no banco
					opALU <= 4'bx; 				// Nao usa ALU, nao importa
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'bx;				// Nao usa ALU, nao importa
					write_enable_reg <= 2'b01;	// Escreve no banco de registradores
					signed_imm_extension <= 1'b0; //Imediato com extensao NAO sinalizada
					mem_byte_mode <= 1'bx;		// Don't care sobre uso da memoria
				end
				
/*----------------------------------------------------------------------------*/
			/* DEFAULT */
			default:
				begin
					reg_dst <= 2'dx;				// Nao escreve bco reg, nao importa
					pc_src = 2'b11;				// Padrao PC+1
					reg_write <= 2'bx;			// Nao escreve no bco, nao importa
					opALU <= 4'b0;					// Nao usa ALU, nao importa
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'b0;				// Nao usa ALU, nao importa
					write_enable_reg <= 2'b00;	// NAO escreve registrador
					signed_imm_extension <= 1'bx; //Don't care imediato
					mem_byte_mode <= 1'bx;		// Don't care sobre uso da memoria
				end
		endcase
	end
	
endmodule