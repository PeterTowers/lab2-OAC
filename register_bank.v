module register_bank(
	input clock,
	input[4:0] read_reg1, read_reg2, write_reg,	
	input [1:0] write_enable,
	input muu_write_enable, movn,
	input [31:0] write_data,
	output reg[31:0] read_data1, read_data2
	);
	
	// Nossos registradores sao de 32 bits e temos 32 deles. Nessa ordem.
	reg[31:0] registers[31:0];
	
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
					if (muu_write_enable || movn )	// Caso um dos sinais ativo, escreve
					registers[write_reg] <= write_data;
					
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
	