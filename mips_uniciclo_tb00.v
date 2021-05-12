/*------------------------------------------------------------------------------
 mips_uniciclo_tb00: Test bench p/ verificar a execucao do codigo no
 * processador MIPS uniciclo desenvolvido neste trabalho.
 *
 * Para executar um codigo escrito em assembly MIPS, ele deve estar
 * pre-compilado e suas areas .text e .data devem ser copiadas para os arquivos
 * 'UnicicloInst.mif' (relativo a parte .text do codigo em assembly MIPS) e
 * 'UnicicloData.mif' (relativo a parte .data do codigo em assembly).
 * 
 * Em seguida, assegure-se que a entidade top-level esta definida como sendo o
 * arquivo 'mips_uniciclo.v' e este arquivo (mips_uniciclo_tb00.v) esta definido
 * como o test bench em Assignments > Settings... > EDA Tool Settings >
 * > Simulation > NativeLink Settings > "Compile test bench:"
 *
 * Caso tudo esteja definido corretamente, compile o projeto e utilize o botao
 * RTL Simulation para executar a simulacao. O valor final de todos os 32
 * registradores sera exibido em forma de texto na tela aberta do ModelSim, ao
 * passo que demais informacoes como o PC, a intrucao executada, operandos da
 * ALU, etc. serao mostrados sequencialmente no grafico da simulacao.
------------------------------------------------------------------------------*/

`timescale 1ps / 1ps  
module mips_uniciclo_tb00;
	reg pc_clock, inst_clock, data_clock, reg_clock, muu_clock;
	wire [31:0] pc, instruction, alu_operand_a, alu_operand_b, ALUresult;
	wire [31:0] t0, t1, t2, t3, t4, t5, t6, t7, hi, lo, memory_write, epc;
	wire [31:0] s0, s1, s2, s3, s4, s5, s6, s7;
	wire alu_zero, cause;
	wire [1:0] write_enable, reg_write;
	
	mips_uniciclo test_unit(
		.pc_clock(pc_clock), 
		.inst_clock(inst_clock),
		.data_clock(data_clock),
		.reg_clock(reg_clock),
		.muu_clock(muu_clock),
		.ALUresult_out(ALUresult),
		.pc_out(pc),
		.instruction_out(instruction),
		.alu_zero_out(alu_zero),
		.write_enable_out(write_enable),
		.alu_operand_a(alu_operand_a),
		.alu_operand_b(alu_operand_b),
		.t0(t0),
		.t1(t1),
		.t2(t2),
		.t3(t3),
		.t4(t4),
		.t5(t5),
		.t6(t6),
		.t7(t7),
		.s0(s0),
		.s1(s1),
		.s2(s2),
		.s3(s3),
		.s4(s4),
		.s5(s5),
		.s6(s6),
		.s7(s7),
		.hi(hi),
		.lo(lo),
		.memory_write(memory_write),
		.reg_write_out(reg_write),
		.epc(epc),
		.cause(cause)
	);
	
	parameter num_cycles = 200;

	initial begin
		pc_clock = 1'b0;
		inst_clock = 1'b0;
		data_clock = 1'b0;
		reg_clock = 1'b0;
		muu_clock = 1'b0;
	end
	
	initial begin	: do_test// Temos varios sinais de clock, pois cada componente precisa ser ativado em um momento diferente.
		integer i, count_empty_instructions;
		count_empty_instructions = 0;
		repeat(num_cycles)
			begin 
				if (count_empty_instructions < 3) begin				
					reg_clock = 1'b0;
					pc_clock = 1'b1;
					#50;
					pc_clock = 1'b0;
					inst_clock = 1'b1;
					#250;
					inst_clock = 1'b0;
					data_clock = 1'b1;
					muu_clock = 1'b1;
					#250;
					data_clock = 1'b0;
					muu_clock = 1'b0;
					reg_clock = 1'b1;
					#50;
					if (instruction == 0)
						count_empty_instructions = count_empty_instructions + 1;
					else
						count_empty_instructions = 0;
				end
			end
			
		for(i = 0; i <=31; i = i + 1) begin
			$display("Register[%0d] = 0x%h", i , mips_uniciclo_tb00.test_unit.reg_bank.registers[i]);
		end
	end
	
endmodule