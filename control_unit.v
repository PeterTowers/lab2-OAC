module control_unit(
	input[0:5] opcode,
	output reg reg_dst, // escolhe qual o registrador em que será salvo. Se so tem 2 é 0, se temos 3, é 1.
	output reg branch, // para as funcoes de jump. 1 é jump
	output reg read_mem,
	output reg mem_to_reg,
	output reg[3:0] opALU,
	output reg write_enable_mem,
	output reg origALU,
	output reg write_enable_reg
	);
	
	initial begin
		write_enable_reg = 1'b0;
		reg_dst = 1'b0;
		branch = 1'b0; 
		read_mem = 1'b0; 
		mem_to_reg = 1'b0;
		opALU = 1'b0;
		write_enable_mem = 1'b0;
		origALU = 1'b0;	
	end
	
	
	always @(*)
	begin
	
		//Ideia: por padrão, todos os sinais recebem zero, e os sinais ativos são reativados abaixo.
		mem_to_reg <= 1'b0; // Se 1, envia dado da memória de volta para o banco de registradores.
		write_enable_mem <= 1'b0; // Se 1, escreve na memória de dados.
		
		case(opcode)
			6'b001000:  //ADDI
				begin
					write_enable_reg <= 1'd1; // Essa operacão escreve no banco de registradores.
					reg_dst <= 1'd0; // Só temos 2 registradores nesse caso.
					opALU <= 4'd1; // Operação Soma.
					origALU <= 1'd1; // O segundo operando da ULA é o imediato.
					write_enable_mem <= 1'b0; //Não escreve na memória
				end
			6'b001100:  //ANDI //TODO: No manual do MIPS diz que a extensão de sinal no ANDI é sempre de zeros, porém, na forma atual está extensão sinalizada.
				begin 
					write_enable_reg <= 1'd1; // Essa operacão escreve no banco de registradores.
					reg_dst <= 1'd0; // Só temos 2 registradores nesse caso.
					opALU <= 4'd3; // Operação And
					origALU <= 1'd1; // O segundo operando da ULA é o imediato.
					write_enable_mem <= 1'b0; //Não escreve na memória
				end
			6'b001101:  //ORI //TODO: No manual do MIPS diz que a extensão de sinal no ANDI é sempre de zeros, porém, na forma atual está extensã sinalizada.
				begin 
					write_enable_reg <= 1'd1; // Essa operacão escreve no banco de registradores.
					reg_dst <= 1'd0; // Só temos 2 registradores nesse caso.
					opALU <= 4'd4; // Operação Or
					origALU <= 1'd1; // O segundo operando da ULA é o imediato.
					write_enable_mem <= 1'b0; //Não escreve na memóriaa
				end
			6'b001110:  //XORI //TODO: No manual do MIPS diz que a extensão de sinal no ANDI é sempre de zeros, porém, na forma atual está extensã sinalizada.
				begin 
					write_enable_reg <= 1'd1; // Essa operacão escreve no banco de registradores.
					reg_dst <= 1'd0; // Só temos 2 registradores nesse caso.
					opALU <= 4'd5; // Operação xor
					origALU <= 1'd1; // O segundo operando da ULA é o imediato.
					write_enable_mem <= 1'b0; //Não escreve na memória
				end
			6'b000000:  //Tipo-R
				begin
					write_enable_reg <= 1'd1; // Essa operacão escreve no banco de registradores.
					reg_dst <= 1'd1; // Temos 3 registradores nesse caso.
					opALU <= 4'd0; // Operação decidida pelo campo funct.
					origALU <= 1'd0; // O segundo operando da ULA é o segundo registrador.
					write_enable_mem <= 1'b0; //Não escreve na memória
				end
			6'b101011:  //SW
				begin
					write_enable_reg <= 1'd0; // Não escreve no banco de registradores.
					reg_dst <= 1'd0; // Temos 2 registradores nesse caso.
					opALU <= 4'd1; // ULA deve somar.
					origALU <= 1'd1; // O segundo operando da ULA é o imediato/offset.
					write_enable_mem <= 1'b1; //Escreve na memória
				end
			6'b100011:  //LW
				begin
					write_enable_reg <= 1'd1; // Escreve no banco de registradores.
					reg_dst <= 1'd0; // Temos 2 registradores nesse caso.
					opALU <= 4'd1; // ULA deve somar.
					origALU <= 1'd1; // O segundo operando da ULA é o imediato/offset.
					write_enable_mem <= 1'b0; //Não Escreve na memória.
					mem_to_reg <= 1'b1; // Se 1, envia a saída da memória para escrever no banco de registrador.
				end
			
			default:
				write_enable_reg <= 1'd0;
				
		endcase
	end
	
	
endmodule