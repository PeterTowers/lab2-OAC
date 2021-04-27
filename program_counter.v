/* 
 * program_counter module: responsible for keeping track of program counter
 * (PC), increasing it at each cycle, branch and jump addresses calculation.
 */
module program_counter(
	input	clk, alu_zero,					// Clock & signal from ALU
	input	[1:0]  pc_src,					// Source signal for PC (j, jr, branch)
	input [31:0] b_address, reg_addr,// Branch & register addresses
	input [25:0] j_address,				// Jump address
	output reg [31:0] pc,				// Output bus
	output link_addr						// Return address for JAL/JALR
	);
	
	// Starts PC at -1 so its first output value is zero
	initial begin
		pc = -1;
	end

/*----------------------------------------------------------------------------*/
   always @(posedge clk) begin
		pc = pc + 1;	// PC always increases by 1
		
		case (pc_src)
			2'b00:	// Branch
				if (alu_zero)
					pc = pc + (b_address << 2);	// Shift left as per how it's implemented
					
			2'b01:	// Unconditional absolute jump (j, jal)
				pc = {pc[31:26], j_address[25:0]};	// PC receives its 4 MSB and the
																// others come from given address
			
			2'b10:	// Unconditional register-indirect jump (jr, jalr)
				pc = reg_addr;		// PC is set to received address
			
			default: // NO OP
				;
		endcase
    end
endmodule	// programCounter