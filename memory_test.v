module memory_test (dataout, datain, addr, we, inclk, outclk);

	// port instantiation

	input   [31:0] datain;
	input   [31:0] addr;
	input   we, inclk, outclk;

	output  [31:0] dataout;

	// instantiating lpm_ram_dq

	lpm_ram_dq ram (.data(datain), .address(addr), .we(we), .inclock(inclk), 
						 .outclock(outclk), .q(dataout));

	// passing the parameter values

	defparam ram.lpm_width = 32;
	defparam ram.lpm_widthad = 32;
	defparam ram.lpm_indata = "REGISTERED";
	defparam ram.lpm_outdata = "REGISTERED";
	defparam ram.lpm_file = "UnicicloInst.mif";

endmodule