module register_bank(
	input clock,
	input[4:0] read_reg1, read_reg2, write_reg,	
	input write_enable,
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
	always @(posedge clock)
	begin
		if(write_enable) // Se o write_enable for 1				
			registers[write_reg] <= write_data; //Escreve no registrador indifcado por write_reg
	end		
	always @*
	begin
		read_data1 <= registers[read_reg1];
		read_data2 <= registers[read_reg2];
	end	

endmodule
	