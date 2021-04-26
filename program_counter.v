/* 
 * program_counter module: responsible for keeping track of program counter
 * (PC), increasing it at each cycle, branch and jump addresses calculation.
 */
module program_counter(
	input		clk, alu_zero,					// Clock & signal from ALU
	input		[1:0]  pc_src,					// Source signal for PC (j, jr, branch)
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
		
		// Branch: occurs when pc_src = 2'b00 and alu_zero is set to 1
		if (!pc_src[1] & !pc_src[0] & alu_zero) begin 
			pc = pc + (b_address << 2);	// Shift left as per how it's implemented
		end
		
		// Unconditional absolute jump (j, jal): occurs when pc_src = 2'b01
		else if (!pc_src[1] & pc_src[0]) begin
			sll_j_address = j_address << 2;	// Jump address is shifted left by 2 bits
			pc = pc[31:28] + sll_j_address[27:0];	// PC receives its 4 MSB and the
		end													// others come from given adress
		
		// Unconditional register-indirect jump (jr, jalr): occurs when pc_src = 2'b10
		else if (pc_src[1] & !pc_src[0]) begin
			pc = reg_addr;		// PC is set to received address
		end
    end
endmodule	// programCounter