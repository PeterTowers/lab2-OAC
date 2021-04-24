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
	wire write_enable_reg; // Se 1, ocorrerá uma escrita no banco de registradores na ubida do clock.
	reg clock;
	
	parameter clock_period = 500;	
	
	//TODO: estes reg são temporário até os outros módulos estarem prontos.
	reg[6:0] pc;	
	
	//Fim dos reg temporários
	
	initial begin
		pc = 0;
		clock = 1'b0;
		#(10* clock_period) $finish;
	end
	
	always begin// Sobe e desce o cinal de clock a cada meio periodo
		#(clock_period/2) clock <= ~clock;		
	end
	always begin// Avança PC
		#clock_period pc <= pc + 1;
	end
	
	//Banco de Registradores
	register_bank reg_bank(
		.clock(clock),
		.read_reg1(instruction[25:21]),
		.read_reg2(instruction[20:16]),
		.write_reg(reg_dst_write),
		.write_enable(write_enable_reg),
		.write_data(ALUresult),
		.read_data1(reg_bank_data1), 
		.read_data2(reg_bank_data2)
	);
	
	//Unidade de Controle
	control_unit control_unit(
		.opcode(instruction[31:26]),
		.reg_dst(reg_dst),
		.branch(),
		.read_mem(),
		.mem_para_reg(),
		.opALU(opALU),
		.write_mem(),
		.origALU(origALU),
		.write_enable_reg(write_enable_reg)
	);
	
	
	//Memória das instruções
	inst_memory memoria2(
		.address(pc),
		.clock(clock),
		.data(),
		.wren(1'b0),
		.q(instruction)
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
		.operation(ALUoperation), //TODO: Tem que delegar a escolha da operação
		.result(ALUresult) //TODO: Coloquei de volta no banco, mas na verdade tem que fazer um mux.
	);
	
	
	
	
	
endmodule