`timescale 1ps / 1ps  
module mips_uniciclo(
	input pc_clock, inst_clock, data_clock, reg_clock, muu_clock,
	
	output [31:0] ALUresult_out, pc_out, instruction_out, alu_operand_a,
	output [31:0] alu_operand_b, t0, t1, t2, t3, t4, t5, t6, t7, hi, lo,
	output [31:0] memory_write,
	output alu_zero_out,
	
	// Saidas p/ debugging; podem ser apagadas de forma segura junto com os
	// respectivos assigns e wires.
	output [31:0] write_on_bank_out,
	output [1:0] write_enable_out, reg_write_out,
	output movn_out, muu_write_enable_out,
	output reg [31:0] epc, // Tratamento de exceções
	output reg cause
	);
	
	wire[31:0] instruction; 	// Saida da mem. de instrucoes. Alimenta controle, bco reg e TODO: Extensao de sinal DONE? -P
	
	wire [1:0] reg_dst; 			// Gerado pela unidade de controle, decide o registrador p/ escrita.
	wire [4:0] reg_dst_write;	// Registrador selecionado para escrita
	wire origALU; 					// Fio para decidir se 2o op da ALU eh imm ou reg
	wire [3:0] opALU;				// Gerado pela unidade de controle, auxilia escolha de op na ALU
	wire [3:0] ALUoperation; 	// Determina operacao executada na ALU
	wire [31:0] reg_bank_data1, reg_bank_data2; // Valores lidos do banco de reg
	wire [31:0] ALUoperand_b; 	// Segundo operando da ALU
	wire [31:0] ALUresult; 		// Resultado da ALU
	wire [31:0] extended_imm;	// Imediato com sinal extendido.
	wire [1:0]  write_enable_reg;	// Determina escrita no bco reg na subida do clk
	wire write_enable_mem; 		// Determina escrita na mem de dados na subida clk
	wire [31:0] mem_data; 		// O dado lido da memoria
	wire [1:0] reg_write; 		// Escolhe o que sera escrito no banco de reg
	wire [31:0] write_on_bank; // Dado a ser escrito no banco
	
	wire equal;						// Seletor do resultado de alu_zero
	wire alu_zero;					// Sinal de controle p/ tomada de decisao do branch
	wire movn;						// Sinal de controle p/ evitar escrita em movn
	
	wire write_epc;				// Escreve no Registrador Error Program Counter (EPC)
	wire cause_int;				// Especifica qual a causa do erro. 0 é OpCode Inválido, e 1 é Overflow
	wire write_cause;				// Escreve no Registrador Cause
	wire overflow;
	
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
	wire [31:0] memory_in;		// Fio do que sera escrito na memoria. Filtrado como Word ou Byte.
	wire [31:0] memory_out;		// Fio do que foi lido da memoria. Filtrado como Word ou Byte.
	wire memory_byte_filter;
	
	/* Expondo os registradores para facilitar na apresentacao e no Debug. */
	wire [31:0] t0_wire, t1_wire, t2_wire, t3_wire, t4_wire, t5_wire, t6_wire;
	wire [31:0] t7_wire, hi_wire, lo_wire;
	
	/* Conexoes de debugging (podem ser apagadas CUIDADOSAMENTE p/ apresentacao) */
	// A ideia é colocar wires aqui p/ fazer debug, caso necessario
	
/*----------------------------------------------------------------------------*/
	// Saidas p/ apresentacao e debugging
	assign ALUresult_out = ALUresult;		// Resultado da ALU
	assign pc_out = pc;							// Program counter
	assign instruction_out = instruction;	// Instrucao pega da memoria
	assign alu_zero_out = alu_zero;			// Saida alu_zero da ALU
	assign alu_operand_a = reg_bank_data1;	// Operador rs da ALU
	assign alu_operand_b = ALUoperand_b;	// Operador rt da ALU
	
	// Saida dos registradores T
	assign t0 = t0_wire;
	assign t1 = t1_wire;
	assign t2 = t2_wire;
	assign t3 = t3_wire;
	assign t4 = t4_wire;
	assign t5 = t5_wire;
	assign t6 = t6_wire;
	assign t7 = t7_wire;
	
	// Registradores internos da MUU
	assign hi = hi_wire;
	assign lo = lo_wire;
	
	// Dados p/ escrita na memoria
	assign memory_write = memory_in;
	
	/* Conexoes de debugging (podem ser apagadas CUIDADOSAMENTE p/ apresentacao) */
	assign write_enable_out = write_enable_reg;
	assign movn_out = movn;
	assign reg_write_out = reg_write;
	assign muu_write_enable_out = muu_write_enable;
	assign write_on_bank_out = write_on_bank;
	
/*----------------------------------------------------------------------------*/

	initial begin
		cause =  1'b0;
		epc = 32'b0;
	end

	

	// Modulo do PC
	program_counter p_counter(
		.clk(pc_clock),
		.pc_src(pc_src),						// Sinal de controle p/ branch
		.alu_zero(alu_zero),					// Sinal de controle caso igual (ou nao: beq/bne)
		.b_address(extended_imm),			// Endereco do branch
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
		.movn(movn),
		.write_data(write_on_bank),
		.read_data1(reg_bank_data1), 
		.read_data2(reg_bank_data2),
		.t0(t0_wire),
		.t1(t1_wire),
		.t2(t2_wire),
		.t3(t3_wire),
		.t4(t4_wire),
		.t5(t5_wire),
		.t6(t6_wire),
		.t7(t7_wire)
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
		.mem_byte_mode(memory_byte_filter),
		.write_epc(write_epc),
		.cause_int(cause_int),
		.write_cause(write_cause),
		.overflow(overflow)
	);
	
	
	//Memoria das instrucoes
	inst_memory memoria_instrucao(
		.address(pc[6:0]),
		.clock(inst_clock),
		.data(), 			// Ninguem vai escrever na memoria de instrucoes
		.wren(1'b0),
		.q(instruction)
	);
	
	// Esse módulo serve para ativar o modo Byte do SB e LB, na hora de ESCREVER na memória de dados.
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
	
	// Esse módulo serve para ativar o modo Byte do SB e LB, na hora de LER da memória de dados.
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
		.option_a(ALUresult),			// Resultado da ALU
		.option_b(mem_data),				// Dado da memoria
		.option_c(return_address),		// Return address (JAL/JALR)
		.option_d(muu_out),				// Resutado da Unidade Multiplicadora
		.selector(reg_write),			// Seletor
		.out(write_on_bank)				// Saida
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
		.equal(equal),
		.result(ALUresult),
		.alu_zero(alu_zero),
		.movn(movn),
		.overflow(overflow)
	);
	
	// Unidade Multiplicadora - MUU
	muu multp_unit(
		.clk(muu_clock), 
		.rs(reg_bank_data1),
		.rt(ALUoperand_b),
		.operation(muu_op),
		.out(muu_out),
		.div_zero(muu_div_zero),
		.hi(hi_wire),
		.lo(lo_wire)
	);
	
	// Controle da Unidade Multiplicadora
	muu_control MUU_controller(
		.funct(instruction[5:0]),
		.operation(muu_op),
		.muu_write_enable(muu_write_enable)
	);
	
	
	// Tratamento de exceção
	always @(posedge reg_clock) begin
		if (write_epc == 1'b1)
			epc = pc;
		
		if (write_cause == 1'b1)
			cause = cause_int;
	end
	
	
endmodule