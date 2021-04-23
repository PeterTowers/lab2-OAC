module mips_uniciclo(output testout);

	
	wire[31:0] instruction; // Sai da memória de instruções e alimenta o controle, o banco de registradores e TODO: Extensão de sinal
	wire[31:0] instruction_test;
	wire[31:0] reg_bank_data1, reg_bank_data2; // São os valores lidos do banco de registradores
	wire reg_dst; // Gerado pela unidade de controle, decide qual o registrador para escrita.
	wire[4:0] reg_dst_write; // Registrador selecionado para escrita
	reg clock;
	
	parameter period = 200;	
	
	//TODO: estes reg são temporário até os outros módulos estarem prontos.
	reg[6:0] pc;	
	
	//Fim dos reg temporários
	
	initial begin
		pc = 0;
		clock = 1'b0;
		#(10* period) $finish;
	end
	
	always begin// Sobe e desce o cinal de clock a cada meio periodo
		#(period/2) clock <= ~clock;		
	end
	always begin// Avança PC
		#period pc <= pc + 1;
	end
	
	//Banco de Registradores
	register_bank reg_bank(
		.clock(clock),
		.read_reg1(instruction[25:21]),
		.read_reg2(instruction[20:16]),
		.write_reg(reg_dst_write),
		.write_enable(0),
		.write_data(0),
		.read_data1(), 
		.read_data2()
	);
	
	//Unidade de Controle
	control_unit control_unit(
		.opcode(instruction[31:26]),
		.reg_dst(reg_dst),
		.branch(),
		.read_mem(),
		.mem_para_reg(),
		.opALU(),
		.write_mem(),
		.orig_alu(),
		.write_reg()
	);
	
	//Memória de Instruções
	instructions_memory inst_memory(
		.clock(clock), 
		.read_address(pc),
		.instruction(instruction)
	);
	
	//Mux para escolher qual vai ser o registrador de escrita.
	mux1 reg_write_mux(
		.option_a(instruction[20:16]),
		.option_b(instruction[15:11]),
		.selector(reg_dst),
		.out(reg_dst_write)
	);
	
	
	//ULA Principal
	alu main_alu(
		.A(reg_bank_data1), 
		.B(reg_bank_data2), 
		.operation(), 
		.out()
	);
	
	inst_memory memoria2(
		.address(pc),
		.clock(clock),
		.data(),
		.wren(1'b0),
		.q(instruction_test)
	);
	
	
	
endmodule