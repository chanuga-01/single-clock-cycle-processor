//Combinational logic required to decode the 32 bit instruction from Instruction Memory
`timescale 1ns / 100ps
module combinationalLogic(INSTRUCTION, WRITEREG, READREG1, READREG2, IMMEDIATE, OFFSET);

   	input [31:0] INSTRUCTION;
    	output [7:0] IMMEDIATE, OFFSET;
    	output [2:0] WRITEREG, READREG1, READREG2;

    //Assign destination register from bits 18 to 16 of the instruction
	assign #1 WRITEREG = INSTRUCTION[18:16];

    //Assign first source register from bits 10 to 8 of the instruction
	assign #1 READREG1 = INSTRUCTION[10:8];

    //Assign second source register from bits 2 to 0 of the instruction
	assign #1 READREG2 = INSTRUCTION[2:0];
	
	//Assign immediate value from bits 7 to 0 of the instruction
    assign #1 IMMEDIATE = INSTRUCTION[7:0];

    //Assign offset value from bits 23 to 16 of the instruction
    assign #1 OFFSET = INSTRUCTION[23:16];

endmodule