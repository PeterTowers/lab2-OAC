`timescale 1ps / 1ps  
module mips_uniciclo(output testout);
	
	wire[31:0] instruction; 	// Sai da memoria de instrucoes e alimenta o controle, o banco de registradores e TODO: Extensao de sinal
	
	wire [1:0] reg_dst; 			// Gerado pela unidade de controle, decide qual o registrador para escrita.
	wire [4:0] reg_dst_write;	// Registrador selecionado para escrita
	wire origALU; 					// Fio para decidir se a ALU operador B usa Imediato ou registrador
	wire [2:0] opALU;				// Gerado pela unidade de controle, ajuda a decidir a operacao da ULA.
	wire [3:0] ALUoperation; 	// Determina operacao executada na ALU
	wire [31:0] reg_bank_data1, reg_bank_data2; // Sao os valores lidos do banco de registradores
	wire [31:0] ALUoperand_b; 	//O segundo operando da ULA.
	wire [31:0] ALUresult; 		//Resultado da ULA
	wire [31:0] sign_extended_imm; // Imediato com sinal extendido.
	wire write_enable_reg; 		// Se 1, ocorrera uma escrita no banco de registradores na subida do clock.
	wire write_enable_mem; 		// Se 1, ocorrera uma escrita na memoria de dados na subida do clock.
	wire [31:0] mem_data; 		// O dado que foi lido na memoria.
	wire mem_to_reg; 				//Se 1, o dado da memoria eh enviado para a escrita do banco de registradores.
	wire [31:0] write_on_bank; // Aquilo que sera escrito no banco
	wire [1:0] pc_src;
	wire alu_zero;
	reg pc_clock, inst_clock, data_clock, reg_clock;
	
	wire [31:0] pc;				// Program counter - determina a instrucao atual
	

	parameter num_cycles = 10;
	
	initial begin
		pc_clock = 1'b0;
		inst_clock = 1'b0;
		data_clock = 1'b0;
		reg_clock = 1'b0;
	end
	
	always begin	// Sobe e desce o sinal de clock de tempo em tempo.
		repeat(num_cycles)
			begin 
				reg_clock = 1'b0;
				pc_clock = 1'b1;
				#50;
				pc_clock = 1'b0;
				inst_clock = 1'b1;
				#250;
				inst_clock = 1'b0;
				data_clock = 1'b1;			
				#250;
				data_clock = 1'b0;
				reg_clock = 1'b1;
				#50;
			end
		$stop;
	end

	// Modulo do PC
	program_counter p_counter(
		.clk(pc_clock),
		.pc_src(pc_src),						// Sinal de controle p/ branch
		.alu_zero(alu_zero),					// Sinal de controle caso igual (ou nao: beq/bne)
		.b_address(sign_extended_imm),	// Endereco do branch
		.reg_addr(reg_bank_data1),			// Endereco do jump vindo de registrador (jr/jalr)
		.j_address(instruction[25:0]),	// Endereco do jump incondicional (j/jal)
		.pc(pc)									// Saida do PC (PC atual)
	);
	
	//Banco de Registradores
	register_bank reg_bank(
		.clock(reg_clock),
		.read_reg1(instruction[25:21]),
		.read_reg2(instruction[20:16]),
		.write_reg(reg_dst_write),
		.write_enable(write_enable_reg),
		.write_data(write_on_bank),
		.read_data1(reg_bank_data1), 
		.read_data2(reg_bank_data2)
	);
	
	//Unidade de Controle
	control_unit control_unit(
		.opcode(instruction[31:26]),
		.funct(instruction[5:0]),
		.reg_dst(reg_dst),
		.pc_src(pc_src),
		.mem_to_reg(mem_to_reg),
		.opALU(opALU),
		.write_enable_mem(write_enable_mem),
		.origALU(origALU),
		.write_enable_reg(write_enable_reg)
	);
	
	
	//Memoria das instrucoes
	inst_memory memoria_instrucao(
		.address(pc[6:0]),
		.clock(inst_clock),
		.data(), 			// Ninguem vai escrever na memoria de instrucoes
		.wren(1'b0),
		.q(instruction)
	);
	
	//Memoria de dados
	data_memory3 memoria_dados(
		.address(ALUresult[6:0]),
		.clock(data_clock),
		.data(reg_bank_data2),
		.wren(write_enable_mem),
		.q(mem_data)
	);
	
	//Mux para escolher qual vai ser o registrador de escrita.
	mux1_5bits reg_write_mux(
		.option_a(instruction[20:16]),
		.option_b(instruction[15:11]),
		.selector(reg_dst),
		.out(reg_dst_write)
	);
	
	//Mux para escolher se a ULA recebe em B um imediato ou o se recebe o segundo valor do Banco de Registradores
	mux1_32bits immediate_reg2_mux(
		.option_a(reg_bank_data2),
		.option_b(sign_extended_imm),
		.selector(origALU),
		.out(ALUoperand_b)
	);
	
	//Mux pera escolher se o que vai para a escrita do banco de registradores eh o resultado da ULA ou o dado da Memoria
	mux1_32bits write_reg_bank_mux(
		.option_a(ALUresult),
		.option_b(mem_data),
		.selector(mem_to_reg),
		.out(write_on_bank)
	);
	
	//Extensor de Sinal
	sign_extender sign_extender(
		.unextended(instruction[15:0]),
		.extended(sign_extended_imm)
	);
	
	//Controle da ULA
	alu_control ALU_control(
		.opALU(opALU),
		.funct(instruction[5:0]),
		.operation(ALUoperation)		
	);
	
	//ULA Principal
	alu main_ALU(
		.A(reg_bank_data1), 
		.B(ALUoperand_b), 
		.operation(ALUoperation),
		.result(ALUresult),
		.alu_zero(alu_zero)
	);
	
	
endmodule