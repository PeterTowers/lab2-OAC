`timescale 1ps / 1ps  
module mips_uniciclo(
		input pc_clock, inst_clock, data_clock, reg_clock,
		output[31:0] ALUresult_out, pc_out, instruction_out, alu_operand_a, alu_operand_b,
		output alu_zero_out
	);
	
	wire[31:0] instruction; 	// Sai da memoria de instrucoes e alimenta o controle, o banco de registradores e TODO: Extensao de sinal
	
	wire [1:0] reg_dst; 			// Gerado pela unidade de controle, decide qual o registrador para escrita.
	wire [4:0] reg_dst_write;	// Registrador selecionado para escrita
	wire origALU; 					// Fio para decidir se a ALU operador B usa Imediato ou registrador
	wire [3:0] opALU;				// Gerado pela unidade de controle, ajuda a decidir a operacao da ULA.
	wire [3:0] ALUoperation; 	// Determina operacao executada na ALU
	wire [31:0] reg_bank_data1, reg_bank_data2; // Sao os valores lidos do banco de registradores
	wire [31:0] ALUoperand_b; 	//O segundo operando da ULA.
	wire [31:0] ALUresult; 		//Resultado da ULA
	wire [31:0] extended_imm; // Imediato com sinal extendido.
	wire write_enable_reg; 		// Se 1, ocorrera uma escrita no banco de registradores na subida do clock.
	wire write_enable_mem; 		// Se 1, ocorrera uma escrita na memoria de dados na subida do clock.
	wire [31:0] mem_data; 		// O dado que foi lido na memoria.
	wire [1:0] reg_write; 				//Se 1, o dado da memoria eh enviado para a escrita do banco de registradores.
	wire [31:0] write_on_bank; // Aquilo que sera escrito no banco
	
	wire equal;						// Seletor do resultado de alu_zero
	wire alu_zero;					// Entrada para tomada de decisao do branch
	
	wire signed_imm_extension;
	
	/* Conexoes da Unidade Multiplicadora */
	wire [3:0] muu_op;			// Operacao a ser executada na MUU
	wire [31:0] muu_out;			// Saida dos resultados da MUU
	wire muu_div_zero;			// Sinaliza divisao por zero
	wire muu_write_enable;		// Sinaliza se a operacao na MUU escreve registrador
	
	/* Conexoes do modulo do Program Counter */
	wire [31:0] pc;				// Program counter - determina a instrucao atual
	wire [31:0] return_address;// Endereco de retorno para instrucoes como JAL/JALR/etc
	wire [1:0]  pc_src;			// Seletor p/ proximo valor de PC

	/* Conexoes do filtro Word-Byte */
	wire [31:0] memory_in;		// Fio que do que será escrito na memória. Filtrado para ser Word ou Byte.
	wire [31:0] memory_out;		// Fio que do que foi lido da memória. Filtrado para ser Word ou Byte.
	wire memory_byte_filter;
	
	
	assign ALUresult_out = ALUresult;
	assign pc_out = pc;
	assign instruction_out = instruction;
	assign alu_zero_out = alu_zero;
	assign alu_operand_a = reg_bank_data1;
	assign alu_operand_b = ALUoperand_b;

	// Modulo do PC
	program_counter p_counter(
		.clk(pc_clock),
		.pc_src(pc_src),						// Sinal de controle p/ branch
		.alu_zero(alu_zero),					// Sinal de controle caso igual (ou nao: beq/bne)
		.b_address(extended_imm),	// Endereco do branch
		.reg_addr(reg_bank_data1),			// Endereco do jump vindo de registrador (jr/jalr)
		.j_address(instruction[25:0]),	// Endereco do jump incondicional (j/jal)
		.pc(pc),									// Saida do PC (PC atual)
		.return_address(return_address)	// Endereco de retorno p/ JAL/JALR/etc
	);
	
	// Banco de Registradores
	register_bank reg_bank(
		.clock(reg_clock),
		.read_reg1(instruction[25:21]),
		.read_reg2(instruction[20:16]),
		.write_reg(reg_dst_write),
		.write_enable(write_enable_reg),
		.muu_write_enable(muu_write_enable),
		.write_data(write_on_bank),
		.read_data1(reg_bank_data1), 
		.read_data2(reg_bank_data2)
	);
	
	//Unidade de Controle
	control_unit control_unit(
		.opcode(instruction[31:26]),
		.funct(instruction[5:0]),
		.rt(instruction[20:16]),
		.reg_dst(reg_dst),
		.pc_src(pc_src),
		.reg_write(reg_write),
		.opALU(opALU),
		.write_enable_mem(write_enable_mem),
		.origALU(origALU),
		.write_enable_reg(write_enable_reg),
		.equal(equal),
		.signed_imm_extension(signed_imm_extension),
		.mem_byte_mode(memory_byte_filter)
	);
	
	
	//Memoria das instrucoes
	inst_memory memoria_instrucao(
		.address(pc[6:0]),
		.clock(inst_clock),
		.data(), 			// Ninguem vai escrever na memoria de instrucoes
		.wren(1'b0),
		.q(instruction)
	);
	
	byte_filter mem_byte_filter_in(
		.in (reg_bank_data2),
		.filter_enable(memory_byte_filter),
		.out(memory_in)	
	);
	
	//Memoria de dados
	data_memory3 memoria_dados(
		.address(ALUresult[6:0]),
		.clock(data_clock),
		.data(memory_in),
		.wren(write_enable_mem),
		.q(mem_data)
	);
	
	byte_filter mem_byte_filter_out(
		.in (mem_data),
		.filter_enable(memory_byte_filter),
		.out(memory_out)	
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
		.option_b(extended_imm),
		.selector(origALU),
		.out(ALUoperand_b)
	);

	// Mux para escolher se o que vai para a escrita do banco de registradores eh
	mux2_32bits write_reg_bank_mux(	// o ALU, memoria, return address ou MUU
		.option_a(ALUresult),		// Resultado da ALU
		.option_b(mem_data),			// Dado da memória
		.option_c(return_address),	// Return address (JAL/JALR)
		.option_d(muu_result),		// Resutado da Unidade Multiplicadora
		.selector(reg_write),		// Seletor
		.out(write_on_bank)			// Saida
	);
	
	//Extensor de Sinal
	sign_extender sign_extender(
		.unextended(instruction[15:0]),
		.signed_imm_extension(signed_imm_extension),
		.extended(extended_imm)
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
		.alu_zero(alu_zero),
		.equal(equal)
	);
	
	// Unidade Multiplicadora - MUU
	muu multp_unit(
		.rs(reg_bank_data1),
		.rt(ALU_operand_b),
		.operation(muu_op),
		.out(muu_result),
		.div_zero(muu_div_zero)
	);
	
	// Controle da Unidade Multiplicadora
	muu_control MUU_controller(
		.funct(instruction[5:0]),
		.operation(muu_op),
		.muu_write_enable(muu_write_enable)
	);
	
	
endmodule