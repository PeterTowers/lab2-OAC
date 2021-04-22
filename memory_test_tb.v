module memory_test_tb;

	reg   [31:0] datain;
	reg   [31:0] addr;
	reg   we, inclk, outclk;

	wire  [31:0] dataout;
	
	memory_test test_unit(
		.datain(datain), 
		.addr(addr),
		.we(we),
		.inclk(inclk),
		.outclk(outclk),
		.dataout(dataout)
	);
		
	
	initial begin
		
		we = 1'b0;		
		addr = 32'h1;
		inclk = 0; #100
		outclk = 0; #100
		inclk = 1; #100
		outclk = 1; #100
		
		$display("dataout: %h", dataout);
	end
endmodule