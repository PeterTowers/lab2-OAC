module programCounter32 (reset, clk, D, Q);
   input	     reset, clk;
	input      [31:0] D;
   output	  [31:0] Q;
   reg        [31:0] Q;
    // Register with active-high clock
   always @ (posedge clk)
      if (reset)
			Q = 0;
		else
			Q = D;
    
endmodule	// programCounter32