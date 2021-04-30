`timescale 1ns / 1ps  

module muu_tb;
	// Inputs
	reg clk;
	reg [31:0] rs, rt;
	reg [3:0] operation;	
	wire [31:0] result;
	wire div_zero;
	
	muu test_unit(
		.clk(clk),
		.rs(rs), 
		.rt(rt),
		.operation(operation),
		.out(result),
		.div_zero(div_zero)
	);
	
	task test_result;
		input [31:0] expected_value;
		begin			
			if (result == expected_value) 
				$display("correct\n");
			else  begin
				$display("INCORRECT");
				$display("Expected: %h; Output: %h\n", expected_value, result);
			end
		end
	endtask
	
	always begin
		clk = 1'b1;
		#250;	// high for 20
		
		clk = 1'b0;
		#250;	// low for 20
	end
	
	initial begin
		/* ---------- MUL ---------- */
		rs = 32'd7;
		rt = 32'd2;
		operation = 4'b0000;	// MUL
		
		#250;	// LOW
		
		$display("%0h * %0h = %0h", rs, rt, result);
		$display("div_zero = %0b", div_zero);
		test_result(32'd14);
		
		#250;	// HIGH
		/* ---------- MUL ---------- */
		
		rs = 32'd7;
		rt = 32'hffff_fffe;
		operation = 4'b0000;	// MUL
		
		#250;	// LOW
		
		$display("%0h * %0h = %0h", rs, rt, result);
		$display("div_zero = %0b", div_zero);
		test_result(32'hffff_fff2);
		
		#250;	// HIGH
		/* ---------- MULT ---------- */
		
		rs = 32'h704D_0054;
		rt = 32'h400B_000C;
		operation = 4'b0001;	// MULT
		
		#250;	// LOW
		
		$display("%0h * %0h = %0h; deve manter valor anterior", rs, rt, result);
		$display("div_zero = %0b", div_zero);
		test_result(32'hffff_fff2);
		
		#250;	//HIGH
		/* ---------- MFHI ---------- */
		
		operation = 4'b0101;	//MFHI
		
		#250;	// LOW
		
		$display("HI = %0h", result);
		test_result(32'h1C18_1369);
		
		#250;	//HIGH
		/* ---------- MFLO ---------- */
		
		operation = 4'b0110;	//MFLO
		
		#250;	// LOW
		
		$display("LO = %0h", result);
		test_result(32'h4738_03F0);
		
		#250;	//HIGH
		/* ---------- MADD ---------- */
		
		// Usando os mesmos rs, rt do ultimo teste
		operation = 4'b0010;	// MADD
		
		#250;	// LOW
		
		$display("Resultados do MADD:");
		$display("%0h * %0h = %0h; deve manter valor anterior", rs, rt, result);
		$display("div_zero = %0b", div_zero);
		test_result(32'h4738_03F0);
		
		#250;	//HIGH
		
		operation = 4'b0101;	//MFHI
		
		#250;	// LOW
		
		$display("HI = %0h", result);
		test_result(32'h3830_26D2);
		
		#250;	//HIGH
		
		operation = 4'b0110;	//MFLO
		
		#250;	// LOW
		
		$display("LO = %0h", result);
		test_result(32'h8E70_07E0);
		
		#250;	//HIGH
		
		/* Zeramento dos registradores HI/LO p/ teste com SUBU */
		rs = 32'h0;
		rt = 32'h0;
		operation = 4'b0001;	// MULT
		
		#250;	// LOW
		#250;	//HIGH
		/* ---------- MSUBU ---------- */
		
		rs = 32'hFFFF_FFFF;	// Unsigned operation
		rt = 32'h2;
		operation = 4'b0011;	// MSUBU
		
		#250;	// LOW
		#250;	//HIGH
		
		operation = 4'b0101;	//MFHI
		
		#250;	// LOW
		
		$display("Resultados do MSUBU:");
		$display("HI = %0h", result);
		test_result(32'hFFFF_FFFF);
		
		#250;	//HIGH
		
		operation = 4'b0110;	//MFLO
		
		#250;	// LOW
		
		$display("LO = %0h", result);
		test_result(32'h2);
		
		#250;	//HIGH
		/* ---------- DIV ---------- */
		
		rs = 32'h21;
		rt = 32'h10;
		operation = 4'b0100;	// DIV
		
		#250;	// LOW
		#250;	//HIGH
		
		operation = 4'b0101;	//MFHI
		
		#250;	// LOW
		
		$display("%0h mod %0h = %0h", rs, rt, result);
		$display("HI = %0h", result);
		test_result(32'h1);
		
		#250;	//HIGH
		
		operation = 4'b0110;	//MFLO
		
		#250;	// LOW
		$display("%0h / %0h = %0h", rs, rt, result);
		$display("LO = %0h", result);
		$display("div_zero = %0b", div_zero);
		test_result(32'h2);
		
		#250;	//HIGH
		/* ---------- DIV by zero ---------- */
		
		rt = 32'h0;
		operation = 4'b0100;	// DIV
		
		#250;	// LOW
		$display("%0h / %0h = %0h; mantem valor anterior", rs, rt, result);
		$display("div_zero = %0b", div_zero);
		
		$stop;
	end
endmodule