module instructions_memory (
	input clock,
	input[31:0] read_address,
	output[31:0] instruction	
	);
	
	//reg [31:0] memory[0:1023];
	//Initialize with a file
	(* ram_init_file = "UnicicloInst.mif" *) reg [31:0] memory[0:1024];
	//initial begin	
		//TODO: aprender como inicilizar mif
	//	$readmemh("UnicicloInst.mif",memory, 0,1023);
	///end
	
	reg [31:0] instruction_content;
	assign instruction = instruction_content;
 
	always @ (posedge clock)
	begin		
		instruction_content = memory[read_address];	
		$display ("Memoria lida: %h", instruction_content);
	end
	
endmodule