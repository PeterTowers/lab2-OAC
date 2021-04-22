`timescale 1ns / 1ps  

module instructions_memory_tb;

	// Inputs
	reg clock;
	reg[31:0] read_address;
	wire[31:0] instruction;
	
	instructions_memory test_unit(
		.clock(clock), 
		.read_address(read_address),
		.instruction(instruction)
	);
	
	task print_pins;
		begin
			$display ("-----------");
			$display ("read_address: %h", read_address);
			$display ("instruction: %h", instruction);		
			$display ("-----------");
		end
	endtask
	
	
	initial begin
		clock = 0; #10
		read_address = 32'd1;
		clock = 1; #10;
		print_pins();
		
	end
endmodule