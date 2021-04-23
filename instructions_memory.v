module instructions_memory (
	input clock,
	input[6:0] read_address,
	output[31:0] instruction	
	);
	
	reg [31:0] memory[0:1023];
	
	
	reg [31:0] instruction_content;
	assign instruction = instruction_content;
	
	initial begin
		memory[0] = 32'b00100000000000000000000000000001; // addi Reg1 Reg1 0x1
		memory[1] = 32'b00100000000000000000000000000010; // addi Reg1 Reg1 0x2
		memory[2] = 32'b00100000000000000000000000000011; // addi Reg1 Reg1 0x3
		memory[3] = 32'b00100000000000000000000000000100; // addi Reg1 Reg1 0x4
		memory[4] = 32'b00100000000000000000000000000101; // addi Reg1 Reg1 0x5
	
	end
 
	always @ (posedge clock)
	begin		
		instruction_content = memory[read_address];	
		$display ("Memoria lida: %h", instruction_content);
	end
	
endmodule