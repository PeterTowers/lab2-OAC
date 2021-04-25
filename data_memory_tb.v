`timescale 1ns / 1ps  

module data_memory_tb;
	
	reg[6:0] address;
	reg clock;
	reg[31:0] data;
	reg wren;
	
	wire[31:0] q;
	
	
	data_memory3 memoria_dados(
		.address(address),
		.clock(clock),
		.data(data),
		.wren(wren),
		.q(q)
	);
	
	initial begin
		address = 7'd0;
		clock = 1'b0;
		data = 32'd0;
		wren = 1'b0;
		
		#100;
		
		$display("q: %h; clock: %b; address: %0d", q, clock,address);
		
		clock = 1'b1;
		#100;
		$display("q: %h; clock: %b; address: %0d", q, clock,address);
		
		
		address = 7'd1;
		#100;
		$display("q: %h; clock: %b; address: %0d", q, clock,address);
		
		clock = 1'b0;
		#100;
		$display("q: %h; clock: %b; address: %0d", q, clock,address);
		
		clock = 1'b1;
		#100;
		$display("q: %h; clock: %b; address: %0d", q, clock,address);
		
	end

endmodule