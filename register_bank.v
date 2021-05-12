module register_bank(
	input clock,
	input[4:0] read_reg1, read_reg2, write_reg,	
	input [1:0] write_enable,
	input muu_write_enable, movn,
	input [31:0] write_data,
	output reg[31:0] read_data1, read_data2,
/*----------------------------------------------------------------------------*/
	// Saida dos valores dos registradores t e s para apresentacao e debuggging
	output [31:0] t0, t1, t2, t3, t4, t5, t6, t7,
	output [31:0] s0, s1, s2, s3, s4, s5, s6, s7
	);
	
	// Nossos registradores sao de 32 bits e temos 32 deles. Nessa ordem.
	reg[31:0] registers[31:0];
	
	// Registradores t e s para apresentacao e debuggging
	assign t0 = registers[8];
	assign t1 = registers[9];
	assign t2 = registers[10];
	assign t3 = registers[11];
	assign t4 = registers[12];
	assign t5 = registers[13];
	assign t6 = registers[14];
	assign t7 = registers[15];
	assign s0 = registers[16];
	assign s1 = registers[17];
	assign s2 = registers[18];
	assign s3 = registers[19];
	assign s4 = registers[20];
	assign s5 = registers[21];
	assign s6 = registers[22];
	assign s7 = registers[23];
	
	integer i;
	initial begin
		for(i = 0; i <= 31; i = i + 1) begin
			registers[i] = 32'd0;
		end
	end
	
	//Sempre que entrar a borda de subida do clock
	always @(posedge clock) begin
		// write_enable = 00, escrita OFF. reg == $zero, proibido
		if( (write_enable != 2'b00) && (write_reg != 0) ) begin
			case (write_enable)
				2'b01:			// Escrita ON
					registers[write_reg] <= write_data;
				
				2'b10: begin	// Escrita condicional
					if (muu_write_enable || movn)	// Caso um dos sinais ativo, escreve
						registers[write_reg] <= write_data;
				end
				
				/* DEFAULT */
				default:
					;		// NO OP
			
			endcase
		end
	end		
	always @*
	begin
		read_data1 <= registers[read_reg1];
		read_data2 <= registers[read_reg2];
	end	

endmodule
	