
`timescale 1ns / 100ps

module controlUnit(INSTRUCTION, MUX1, MUX2, MUX4, ALUOP, WRITEENABLE, JUMP, BRANCH, WRITE, READ, BUSYWAIT);

    	input BUSYWAIT;
        input [31:0] INSTRUCTION;
    	reg [7:0] OPCODE;
    	output reg MUX1, MUX2, MUX4, WRITEENABLE, JUMP, BRANCH, WRITE, READ;
    	output reg [2:0] ALUOP;
    
    	always @(INSTRUCTION)
    		begin

            if (BUSYWAIT == 1'b1)
            begin        
                WRITEENABLE = 0;
            end

            if (BUSYWAIT == 1'b0) 
            begin
                OPCODE = INSTRUCTION[31:24];

                case(OPCODE)

                //Calling loadi
                8'b00000000: 
                begin
                    WRITEENABLE = 1;   
                    MUX1 = 0;   	//Doesnt matter
                    MUX2 = 0;   	//Selecting the immediate operand
                    ALUOP = 3'b000; //Selecting the FORWARD operation from ALU
                    JUMP = 0;		//Not a jump instruction
                    BRANCH = 0;		//Not a branch instruction
                    MUX4 = 0;       //ALURESULT is stored in register
                    WRITE = 0;      //Write signal for Data Memory
                    READ = 0;       //Read signal for Data Memory
                end

                //Calling mov
                8'b00000001:
                begin
                    WRITEENABLE = 1; 
                    MUX1 = 0;   	//Selecting the positive number
                    MUX2 = 1;   	//Selecting the output of the MUX1
                    ALUOP = 3'b000;	//Selecting the FORWARD operation from ALU
                    JUMP = 0;		//Not a jump instruction
                    BRANCH = 0;		//Not a branch instruction
                    MUX4 = 0;       //ALURESULT is stored in register
                    WRITE = 0;      //Write signal for Data Memory
                    READ = 0;       //Read signal for Data Memory
                end

                //Calling add
                8'b00000010: 
                begin
                    WRITEENABLE = 1;   
                    MUX1 = 0;    	//Selecting the positive number
                    MUX2 = 1;   	//Selecting the output of the MUX1
                    ALUOP = 3'b001; //Selecting the ADD operation from ALU
                    JUMP = 0;		//Not a jump instruction
                    BRANCH = 0;		//Not a branch instruction
                    MUX4 = 0;       //ALURESULT is stored in register
                    WRITE = 0;      //Write signal for Data Memory
                    READ = 0;       //Read signal for Data Memory
                end
                    
                //Calling sub 
                8'b00000011: 
                begin
                    WRITEENABLE = 1;   
                    MUX1 = 1;   	//Selecting the negative number
                    MUX2 = 1;   	//Selecting the output of the MUX1
                    ALUOP = 3'b001;	//Selecting the ADD operation from ALU
                    JUMP = 0;		//Not a jump instruction
                    BRANCH = 0;		//Not a branch instruction
                    MUX4 = 0;       //ALURESULT is stored in register
                    WRITE = 0;      //Write signal for Data Memory
                    READ = 0;       //Read signal for Data Memory
                end

                //Calling and
                8'b00000100: 
                begin
                    WRITEENABLE = 1;   
                    MUX1 = 0;   	//Selecting the positive number
                    MUX2 = 1;   	//Selecting the output of the MUX1
                    ALUOP = 3'b010;	//Selecting the AND operation from ALU
                    JUMP = 0;		//Not a jump instruction
                    BRANCH = 0;		//Not a branch instruction
                    MUX4 = 0;       //ALURESULT is stored in register
                    WRITE = 0;      //Write signal for Data Memory
                    READ = 0;       //Read signal for Data Memory
                end

                //Calling or
                8'b00000101: 
                begin
                    WRITEENABLE = 1;   
                    MUX1 = 0;    	//Selecting the positive number
                    MUX2 = 1;   	//Selecting the output of the MUX1
                    ALUOP = 3'b011; //selecting the OR operation from ALU
                    JUMP = 0;		//Not a jump instruction
                    BRANCH = 0;		//Not a branch instruction
                    MUX4 = 0;       //ALURESULT is stored in register
                    WRITE = 0;      //Write signal for Data Memory
                    READ = 0;       //Read signal for Data Memory
                end

                //Calling j
                8'b00000110: 
                begin
                    WRITEENABLE = 0;   
                    MUX1 = 0;    	//Doesnt matter
                    MUX2 = 1;   	//Doesnt matter
                    ALUOP = 3'b000; //Doesnt matter
                    JUMP = 1;		//Selecting jump instruction
                    BRANCH = 0;		//Not a branch instruction
                    MUX4 = 0;       //ALURESULT is stored in register
                    WRITE = 0;      //Write signal for Data Memory
                    READ = 0;       //Read signal for Data Memory
                end

                //Calling beq
                8'b00000111: 
                begin
                    WRITEENABLE = 1;   
                    MUX1 = 1;    	//Selecting the negative number
                    MUX2 = 1;   	//Selecting the output of the MUX1
                    ALUOP = 3'b001; //selecting the ADD operation from ALU
                    JUMP = 0;		//Not a jump instruction
                    BRANCH = 1;		//Selecting branch instruction
                    MUX4 = 0;       //ALURESULT is stored in register
                    WRITE = 0;      //Write signal for Data Memory
                    READ = 0;       //Read signal for Data Memory
                end

                //Calling mult
                8'b00001000: 
                begin
                    WRITEENABLE = 1;   
                    MUX1 = 0;    	//Selecting the positive number
                    MUX2 = 1;   	//Selecting the output of the MUX1
                    ALUOP = 3'b100; //selecting the MULTIPLY operation from ALU
                    JUMP = 0;		//Not a jump instruction
                    BRANCH = 0;		//Selecting branch instruction
                    MUX4 = 0;       //ALURESULT is stored in register
                    WRITE = 0;      //Write signal for Data Memory
                    READ = 0;       //Read signal for Data Memory
                end

                //Calling sll and srl
                8'b00001001: 
                begin
                    WRITEENABLE = 1;   
                    MUX1 = 0;    	//Doesnt matter
                    MUX2 = 0;   	//Selecting the immediate operand
                    ALUOP = 3'b101; //selecting the L_SHIFT operation from ALU
                    JUMP = 0;		//Not a jump instruction
                    BRANCH = 0;		//Selecting branch instruction
                    MUX4 = 0;       //ALURESULT is stored in register
                    WRITE = 0;      //Write signal for Data Memory
                    READ = 0;       //Read signal for Data Memory
                end

                //Calling sra
                8'b00001010: 
                begin
                    WRITEENABLE = 1;   
                    MUX1 = 0;    	//Doesnt matter
                    MUX2 = 0;   	//Selecting the immediate operand
                    ALUOP = 3'b110; //selecting the A_SHIFT operation from ALU
                    JUMP = 0;		//Not a jump instruction
                    BRANCH = 0;		//Selecting branch instruction
                    MUX4 = 0;       //ALURESULT is stored in register
                    WRITE = 0;      //Write signal for Data Memory
                    READ = 0;       //Read signal for Data Memory
                end

                //Calling ror
                8'b00001011: 
                begin
                    WRITEENABLE = 1;   
                    MUX1 = 0;    	//Doesnt matter
                    MUX2 = 0;   	//Selecting the immediate operand
                    ALUOP = 3'b111; //selecting the ROTATE operation from ALU
                    JUMP = 0;		//Not a jump instruction
                    BRANCH = 0;		//Selecting branch instruction
                    MUX4 = 0;       //ALURESULT is stored in register
                    WRITE = 0;      //Write signal for Data Memory
                    READ = 0;       //Read signal for Data Memory
                end

                //Calling bne
                8'b00001100: 
                begin
                    WRITEENABLE = 1;   
                    MUX1 = 1;    	//Selecting the negative number
                    MUX2 = 1;   	//Selecting the output of the MUX1
                    ALUOP = 3'b001; //selecting the ADD operation from ALU
                    JUMP = 1;		//Selecting jump instruction
                    BRANCH = 1;		//Selecting branch instruction
                    MUX4 = 0;       //ALUOP is stored in register
                    WRITE = 0;      //Write signal for Data Memory
                    READ = 0;       //Read signal for Data Memory
                end

                //Calling lwd
                8'b00001101: 
                begin
                    WRITEENABLE = 1;   
                    MUX1 = 0;    	//Selecting the positive number
                    MUX2 = 1;   	//Selecting the output of the MUX1
                    ALUOP = 3'b000; //selecting the FORWARD operation from ALU
                    JUMP = 0;		//Selecting jump instruction
                    BRANCH = 0;		//Selecting branch instruction
                    MUX4 = 1;       //Loaded to register from Data Memory
                    WRITE = 0;      //Write signal for Data Memory
                    READ = 1;       //Read signal for Data Memory
                end

                //Calling lwi
                8'b00001110: 
                begin
                    WRITEENABLE = 1;   
                    MUX1 = 0;    	//Selecting the positive number
                    MUX2 = 0;   	//Selecting the immediate value
                    ALUOP = 3'b000; //selecting the FORWARD operation from ALU
                    JUMP = 0;		//Selecting jump instruction
                    BRANCH = 0;		//Selecting branch instruction
                    MUX4 = 1;       //Loaded to register from Data Memory
                    WRITE = 0;      //Write signal for Data Memory
                    READ = 1;       //Read signal for Data Memory
                end

                //Calling swd
                8'b00001111: 
                begin
                    WRITEENABLE = 1;   
                    MUX1 = 0;    	//Selecting the positive number
                    MUX2 = 1;   	//Selecting the output of the MUX1
                    ALUOP = 3'b000; //selecting the FORWARD operation from ALU
                    JUMP = 0;		//Selecting jump instruction
                    BRANCH = 0;		//Selecting branch instruction
                    MUX4 = 0;       //ALURESULT is stored in register
                    WRITE = 1;      //Write signal for Data Memory
                    READ = 0;       //Read signal for Data Memory
                end

                //Calling swi
                8'b00010000: 
                begin
                    WRITEENABLE = 1;   
                    MUX1 = 0;    	//Selecting the positive number
                    MUX2 = 0;   	//Selecting the immediate value
                    ALUOP = 3'b000; //selecting the FORWARD operation from ALU
                    JUMP = 0;		//Selecting jump instruction
                    BRANCH = 0;		//Selecting branch instruction
                    MUX4 = 0;       //ALURESULT is stored in register
                    WRITE = 1;      //Write signal for Data Memory
                    READ = 0;       //Read signal for Data Memory
                end
		endcase
            end
        end

endmodule