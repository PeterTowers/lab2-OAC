module pcPlusFour (clk, pc, out);
	input      clk;
   input      [31:0] pc;
   output	  [31:0] out;
   reg        [31:0] out;
    // Register with active-high clock
   always @ (posedge clk)
      out <= pc + 4;
    
endmodule	// programCounter32