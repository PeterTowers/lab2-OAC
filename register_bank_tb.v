`timescale 1ns / 1ps  

module register_bank_tb;

	// Inputs
	reg clock;
	reg[4:0] read_reg1, read_reg2, write_reg;	
	reg write_enable;
	reg [31:0] write_data;
	wire [31:0] read_data1, read_data2;
	
	register_bank test_unit(
		.clock(clock), 
		.read_reg1(read_reg1),
		.read_reg2(read_reg2),
		.write_reg(write_reg),
		.write_enable(write_enable),
		.write_data(write_data),
		.read_data1(read_data1),
		.read_data2(read_data2)
	);
	
	
	task print_pins;
		begin
			$display ("-----------");
			$display ("read_reg1: %0d", read_reg1);
			$display ("read_reg2: %0d", read_reg2);
			$display ("write_reg: %0d", write_reg);
			$display ("write_enable: %b", write_enable);
			$display ("write_data: %0h", write_data);
			$display ("read_data1: %0h", read_data1);
			$display ("read_data2: %0h", read_data2);
			$display ("-----------");
		end
	endtask
	
	
	task test_result;
		input [31:0] expected_value;
		input [31:0] got_value;
		begin			
			if (got_value == expected_value) 
				$display("correct");
			else  
				$display("INCORRECT");
		end
	endtask
	
	initial begin
		clock = 0; #10
		
		read_reg1 = 5'd5;
		read_reg2 = 5'd6;
		write_enable = 1'b0;
			
		//Teste 1: Ler dos dois registradores		
		clock = 1; #10
		
		
		print_pins();
		test_result(read_data1, 32'd0);
		test_result(read_data2, 32'd0);
		
		//Teste 2: Escrever e ler do registrador no mesmo momento, e tentar ler no proximo clock
		clock = 0; #10
		
		write_enable = 1'b1;
		write_reg = 5'd5; 
		write_data = 32'hFADAF0FA;
		#5
		clock = 1; #5
		
		
		print_pins();
		//test_result(read_data1, 32'd0); // Modificado.
		
		clock = 0; #10	
		write_enable = 1'b0;	// desligamos o modo write.
		clock = 1; #10
		
		print_pins();
		test_result(read_data1, 32'hFADAF0FA); // A leitura no proximo clock deve funcionar
		
		
	end
endmodule