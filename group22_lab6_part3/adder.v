`timescale 1ns / 100ps
module pc_adder(INPUT, BUSYWAIT, PC_OUTPUT);

	input BUSYWAIT;
	input [31:0] INPUT;
	output reg [31:0] PC_OUTPUT; // Must be reg to use in always block

	always @(*) begin
		if (BUSYWAIT == 1'b0)
			PC_OUTPUT = INPUT + 4;
		else
		
			PC_OUTPUT = INPUT; // Hold current PC if busywait is high
	end

endmodule



module offset_adder(PC_OUTPUT, OFFSET, OUTPUT);

	//Offset adder to add the offset to existing PC counter, i.e. make the jump/branch

	input [31:0] PC_OUTPUT;
	input [7:0] OFFSET;
	output [31:0] OUTPUT;

	//Wire to store the offset sign extended and bit shifted to 32 bits 
	
	wire [29:0] EXTENDED_OFFSET;
	wire [31:0] SHIFTED_OFFSET;
	
	//Sign extend the offset to 30 bits

	assign EXTENDED_OFFSET = {{22{OFFSET[7]}}, OFFSET};

	//Bit shift to left by 2 bits

	assign SHIFTED_OFFSET = {EXTENDED_OFFSET, 2'b00};
	assign #2 OUTPUT = PC_OUTPUT + SHIFTED_OFFSET;

endmodule


	
	