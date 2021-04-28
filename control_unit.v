module control_unit(
	input[0:5] opcode, funct,		// Campos "opcode" e "funct"
	input[4:0] rt,						// Registrador rt p/ instrucoes BGEZ/BGEZAL
	
	output reg [1:0] pc_src,		// Determina a escolha do proximo PC
	output reg [1:0] reg_dst, 		// Escolhe o reg em que sera salvo P/ instrucao
											// com 2 eh 0, p/ 3, eh 1, PC eh 2.
	output reg [1:0] reg_write,	// Escolhe qual dado sera salvo no bco de reg
											// 00 é reg, 01 mem, 10 return address
	output reg[2:0] opALU,			// Operacao a ser executada na ALU
	output reg write_enable_mem,	// Habilita escrita na memoria de dados
	output reg origALU,				// Origem do 2o operando da ALU
	output reg write_enable_reg,	// Habilita escrita no banco de registradores
	output reg equal					// Condicao de escolha entre resultado BEQ/BNE
	);

	// Definicao das condicoes iniciais
	initial begin
		reg_dst = 2'b0;
		pc_src = 2'b11;				// Indica saida simples (PC+1)
		reg_write = 2'b00;
		opALU = 3'b0;
		write_enable_mem = 1'b0;
		origALU = 1'b0;
		write_enable_reg = 1'b0;
		equal = 1'b1;
	end	
	
	always @(*) begin
		case(opcode)
/*----------------------------------------------------------------------------*/
			/* Instrucoes tipo R */
			6'b000000: begin					
				case (funct)
					6'b00_1001: begin	// JALR
						reg_dst <= 2'd2;				// Instrucao salva pc+1 em $ra
						pc_src = 2'b10;				// PC = rs
						reg_write <= 2'b00;			// Escreve return address no banco
						opALU <= 3'bx;					// Nao usa ALU, nao importa
						write_enable_mem <= 1'b0;	// NAO escreve na memoria
						origALU <= 1'd0;				// 2o operando da ALU eh o 2o reg
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b00_1000: begin	// JR
						reg_dst <= 2'd1;				// Temos 3 registradores nesse caso
						pc_src = 2'b10;				// PC = rs
						reg_write <= 2'bx;			// Nao escreve bco reg, nao importa
						opALU <= 3'bx;					// Nao usa ALU, nao importa
						write_enable_mem <= 1'b0;	// NAO escreve na memoria
						origALU <= 1'd0;				// 2o operando da ALU eh o 2o reg
						write_enable_reg <= 1'b0;	// NAO escreve no banco de reg
					end
					
					/* DEFAULT */
					default: begin
						reg_dst <= 2'd1;				// Temos 3 registradores nesse caso
						pc_src <= 2'b11;				// PC = PC+1 (nao faz branch ou jump)
						reg_write <= 2'b00;			// Escreve resultado da ALU no banco
						opALU <= 3'b110;				// Avaliar campo funct na alu_control
						write_enable_mem <= 1'b0;	// NAO escreve na memoria
						origALU <= 1'd0;				// 2o operando da ALU eh o 2o reg
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					/* TODO:
					6'b01_1010: begin	// DIV
						pc_src = 2'b11;				// PC = PC+1
						opALU <= 3'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b01_0000: begin	// MFHI
						pc_src = 2'b11;				// PC = PC+1
						opALU <= 3'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b01_0010: begin	// MFLO
						pc_src = 2'b11;				// PC = PC+1
						opALU <= 3'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b00_0000: begin	// SLL
						pc_src = 2'b11;				// PC = PC+1
						opALU <= 3'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b10_1010: begin	// SLT
						pc_src = 2'b11;				// PC = PC+1
						opALU <= 3'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b00_0011: begin	// SRA
						pc_src = 2'b11;				// PC = PC+1
						opALU <= 3'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b00_0111: begin	// SRAV
						pc_src = 2'b11;				// PC = PC+1
						opALU <= 3'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					
					6'b00_0010: begin	// SRL
						pc_src = 2'b11;				// PC = PC+1
						opALU <= 3'b0;					// Operacao ??? na ALU
						write_enable_reg <= 1'b1;	// Escreve no banco de reg
					end
					*/
				endcase
			end

/*----------------------------------------------------------------------------*/
			/* Instrucoes tipo I */				
			6'b001000:  //ADDI
				begin
					reg_dst <= 2'd0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b11;				// PC = PC+1
					reg_write <= 2'b00;			// Escreve resultado da ALU no banco
					opALU <= 3'b000;				// Operacao de soma na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1; 				// 2o operando da ALU eh o imediato
					write_enable_reg <= 1'd1;	// Escreve no banco de registradores
				end
				
			6'b001100:  //ANDI //TODO: No manual do MIPS diz que a extensao de sinal no ANDI eh sempre de zeros, porem, na forma atual esta extensao sinalizada.
				begin 
					reg_dst <= 2'd0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b11;				// PC = PC+1
					reg_write <= 2'b00;			// Escreve resultado da ALU no banco
					opALU <= 3'b010;				// Operacao AND na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh o imediato
					write_enable_reg <= 1'd1;	// Escreve no banco de registradores
				end
				
			6'b000100:	// BEQ
				begin
					reg_dst <= 2'd0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b00;				// Branch
					reg_write <= 2'bx;			// Nao escreve no bco, nao importa
					opALU <= 3'b001;				// Operacao de subtracao na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh o imediato
					write_enable_reg <= 1'd0;	// NAO escreve no bco de registradores
					equal <= 1'b1;					// Testa igualdade na ALU
				end
			
			6'b000001:	// "REGIMM" - BGEZ/BGEZAL
				begin
					pc_src = 2'b00;				// Branch
					reg_write <= 2'b10;			// Qnd escreve bco, escreve return address
					opALU <= 3'b111;				// Operacao de especial na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh o imediato
					
					if (rt == 5'b00001) begin	// BEGEZ
						reg_dst <= 2'd0;				// Apenas 2 registradores nesse caso
						write_enable_reg <= 1'd0;	// NAO escreve no bco de registradores
					end
					
					else begin						// BEGEZAL
						reg_dst <= 2'd2;				// Instrucao salva pc+1 em $ra
						write_enable_reg <= 1'd1;	// Escreve no banco de registradores
					end
				end
			
			6'b000101:	// BNE
				begin
					reg_dst <= 2'd0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b00;				// Branch
					reg_write <= 2'bx;			// Nao escreve no bco, nao importa
					opALU <= 3'b001;				// Operacao de subtracao na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh o imediato
					write_enable_reg <= 1'd0;	// NAO escreve no bco de registradores
					equal <= 1'b0;					// Testa desigualdade na ALU
				end
				
			6'b100011:  //LW
				begin
					reg_dst <= 2'b0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b11;				// PC = PC+1
					reg_write <= 2'b01;			// Escreve dado da memoria no bco de reg
					opALU <= 3'b000;				// Operacao de soma na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh imediato/offset
					write_enable_reg <= 1'd1;	// Escreve no banco de registradores
				end
				
			6'b001101:  //ORI //TODO: No manual do MIPS diz que a extensao de sinal no ANDI eh sempre de zeros, porem, na forma atual esta extensao sinalizada.
				begin 
					reg_dst <= 2'd0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b11;				// PC = PC+1
					reg_write <= 2'b00;			// Escreve resultado da ALU no banco
					opALU <= 3'b100;				// Operacao OR na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh o imediato
					write_enable_reg <= 1'd1;	// Escreve no banco de registradores
				end
			
			6'b101011:  //SW
				begin
					reg_dst <= 2'd0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b11;				// PC = PC+1
					reg_write <= 2'bx;			// Nao escreve no bco, nao importa
					opALU <= 3'b000;				// Operacao de soma na ALU
					write_enable_mem <= 1'b1;	// Escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh imediato/offset
					write_enable_reg <= 1'd0;	// NAO escreve registrador
				end
				
			
			
			6'b001110:  //XORI //TODO: No manual do MIPS diz que a extensao de sinal no ANDI eh sempre de zeros, porem, na forma atual esta extensao sinalizada.
				begin 
					reg_dst <= 2'd0;				// Apenas 2 registradores nesse caso
					pc_src = 2'b11;				// PC = PC+1
					reg_write <= 2'b00;			// Escreve resultado da ALU no banco
					opALU <= 3'b101;				// Operacao XOR na ALU
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd1;				// 2o operando da ALU eh o imediato
					write_enable_reg <= 1'd1;	// Escreve no banco de registradores
				end
			
			6'b011100:  //MUL - SPECIAL2
				begin
					reg_dst <= 2'd1;				// Temos 3 registradores nesse caso
					pc_src = 2'b11;				// PC = PC+1
					reg_write <= 2'b00;			// Escreve resultado da ALU no banco
					opALU <= 3'd0;					// Operacao decidida pelo campo funct
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'd0;				// 2o operando da ALU eh o 2o reg
					write_enable_reg <= 1'd1;	// Escreve no banco de registradores
				end
				
/*----------------------------------------------------------------------------*/
			/* Instrucoes tipo J */
			6'b000010:	// J (jump)
				begin
					reg_dst <= 2'bx;				// Nao escreve bco reg, nao importa
					pc_src = 2'b01;				// Jump incondicional
					reg_write <= 2'bx;			// Nao escreve no bco, nao importa
					opALU <= 3'bx;					// Nao usa ALU, nao importa
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'bx; 				// Nao usa ALU, nao importa
					write_enable_reg <= 1'b0;	// NAO escreve registrador
				end
				
			6'b000011:	// JAL (jump and link)	TODO
				begin
					reg_dst <= 2'd2; 				// Instrucao salva pc+1 em $ra
					pc_src = 2'b01;				// Jump incondicional
					reg_write <= 2'b10;			// Escreve return address no banco
					opALU <= 3'bx; 				// Nao usa ALU, nao importa
					write_enable_mem <= 1'b0;	// NAO escreve na memoria
					origALU <= 1'bx;				// Nao usa ALU, nao importa
					write_enable_reg <= 1'b1;	// Escreve no banco de registradores
				end
				
/*----------------------------------------------------------------------------*/
			/* DEFAULT */
			default:
				begin
					reg_dst <= 2'd0;
					pc_src = 2'b11;
					reg_write <= 2'b00;
					opALU <= 3'b0; 
					write_enable_reg <= 1'b0;
					origALU <= 1'b0;
					write_enable_mem <= 1'b0; 					
				end
		endcase
	end
	
endmodule