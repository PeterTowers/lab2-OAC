/* 
 * program_counter module: responsible for keeping track of program counter
 * (PC), increasing it at each cycle, branch and jump addresses calculation.
 */
module program_counter(
	input		clk,								// Clock
	input		branch, alu_zero, jump,	jr,// Control signals for branch and jump
	input    [31:0] b_address, reg_addr,// Branch & register addresses
	input    [25:0] j_address,				// Jump address
	output	[31:0] out						// Output bus
	);
   
	reg [31:0] pc;					// PC (program counter) register
	reg [27:0] sll_j_address;	// 28 bit register for twice shifted left j_address
	
	// Output is equal to PC
	assign out = pc;
	
	// Starts PC at -1 so its first output value is zero
	initial begin
		pc = -1;
	end

/*----------------------------------------------------------------------------*/
   always @(*) begin
		pc = pc + 1;	// PC always increases by 1
		
		if (branch & alu_zero) begin	// If there's a branch PC = PC + b_address*4
			pc = pc + (b_address << 2);	// Shift left as per how it's implemented
		end
		
		else if (jump) begin				// Unconditional absolute jump
			sll_j_address = j_address << 2;	// Jump address is shifted left by 2 bits
			pc = pc[31:28] + sll_j_address[27:0];	// PC receives its 4 MSB and the
		end													// others come from given adress
		
		else if (jr) begin	// Unconditional register-indirect jump
			pc = reg_addr;		// PC is set to received address
		end
    end
endmodule	// programCounter