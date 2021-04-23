module mux1( option_a, option_b, selector, out);
 
	input wire option_a, option_b; // As entradas sao option_a e option_b
	input wire selector; // O sinal de selecao é selector
	output wire out; // O sinal de saida é out
	wire S0_inv, a1, b1;
	 
	not u1( S0_inv, selector );
	and u2( a1, S0_inv, option_a );
	and u3( b1, selector, option_b );
	or  u4( out, a1, b1 );
	 
endmodule