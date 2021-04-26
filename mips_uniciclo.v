module mips_uniciclo(output testout);

	
	wire[31:0] instruction; // Sai da memória de instruções e alimenta o controle, o banco de registradores e TODO: Extensão de sinal
	
	
	wire reg_dst; // Gerado pela unidade de controle, decide qual o registrador para escrita.
	wire[4:0] reg_dst_write; // Registrador selecionado para escrita
	wire origALU; // Fio para decidir se a ALU operador B usa Imediato ou registrador
	wire[3:0] opALU; // Gerado pela unidade de controle, ajuda a decidir a operação da ULA.
	wire[5:0] ALUoperation; // Escolhe se ULA vai somar, subtrair, etc.
	wire[31:0] reg_bank_data1, reg_bank_data2; // São os valores lidos do banco de registradores
	wire[31:0] ALUoperand_b; //O segundo operando da ULA.
	wire[31:0] ALUresult; //Resultado da ULA
	wire[31:0] sign_extended_imm; // Imediato com sinal extendido.
	wire write_enable_reg; // Se 1, ocorrerá uma escrita no banco de registradores na subida do clock.
	wire write_enable_mem; // Se 1, ocorrerá uma escrita na memória de dados na subida do clock.
	wire [31:0] mem_data; // O dado que foi lido na memória.
	wire mem_to_reg; //Se 1, o dado da memória é enviado para a escrita do banco de registradores.
	wire [31:0] write_on_bank; // Aquilo que será escrito no banco
	reg clock;
	
	parameter clock_period = 500;	
	
	//TODO: estes reg são temporário até os outros módulos estarem prontos.
	reg[31:0] pc;	
	
	//Fim dos reg temporários
	
	initial begin
		pc = 0;
		clock = 1'b0;
		#(10* clock_period) $stop;
	end
	
	always begin// Sobe e desce o cinal de clock a cada meio periodo
		#(clock_period/2) clock = ~clock;		
	end
	always begin// Avança PC
		#clock_period pc = pc + 1;
	end

	// Modulo do PC
	program_counter p_counter(
		.clk(clock),
		.branch(branch),			// Sinal de controle p/ branch
		.alu_zero(alu_zero),		// Sinal de controle caso igual (ou não: beq/bne)
		.jump(jump),				// Sinal de controle p/ jump incondicional (j/jal)
		.jr(jr),						// Sinal de controle p/ jump com registrador (jr/jalr)
		.b_address(b_address),	// Endereco do branch
		.reg_addr(reg_addr),		// Endereco do jump vindo de registrador (jr/jalr)
		.j_address(j_address),	// Endereco do jump incondicional (j/jal)
		.out(pc)						// Saida do PC (PC atual) TODO: definir p/ onde vai (variavel pc eh ok?)
	);
	
	//Banco de Registradores
	register_bank reg_bank(
		.clock(clock),
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
		.branch(),	// TODO
		.jump(),		// TODO
		.mem_to_reg(mem_to_reg),
		.opALU(opALU),
		.write_enable_mem(write_enable_mem),
		.origALU(origALU),
		.write_enable_reg(write_enable_reg)
	);
	
	
	//Memória das instruções
	inst_memory memoria_instrucao(
		.address(pc[6:0]),
		.clock(clock),
		.data(), // Ninguem vai escrever na memória de instruções
		.wren(1'b0),
		.q(instruction)
	);
	
	//Memória de dados
	data_memory3 memoria_dados(
		.address(ALUresult[6:0]),
		.clock(clock),
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
	
	//Mux pera escolher se o que vai para a escrita do banco de registradores é o resultado da ULA ou o dado da Memória
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
		.result(ALUresult) 
	);
	
	
endmodule