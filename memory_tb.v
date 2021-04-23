module memory_tb;
	
	reg	[15:0]  address;
	reg	  clock;
	reg	[31:0]  data;
	reg	  wren;
	wire	[31:0]  q;
	
	memory test_unit(address, clock, data, wren, q);
	integer i;
	initial begin
		wren = 1'b0;	
		
		for(i=0; i <100; i = i + 1) begin
			address = i;
			clock = 0;
			#100;
			clock = 1;
			#100;
			$display("q %0d : %h", i,q);
		end
	end

endmodule