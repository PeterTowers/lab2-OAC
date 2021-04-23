module mux1_5bits_tb;

	reg [4:0] option_a;
	reg [4:0] option_b;
	reg selector;
	wire [4:0] out;
	
	mux1_5bits test_unit(
		.option_a(option_a), 
		.option_b(option_b),
		.selector(selector),
		.out(out)
	);
	
	initial begin		
		option_a = 5'b00011;
		option_b = 5'b11111;
		selector = 1'b0;
		#100;
		$display("selector: %b; out: %b", selector, out);
		
		selector = 1'b1;
		#100;
		$display("selector: %b; out: %b", selector, out);
	end
	
endmodule