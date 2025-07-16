//Bottom level module inclusion
`timescale 1ns / 100ps

`include "alu.v"            
`include "reg.v" 	         
`include "combinationalLogic.v"  
`include "controlUnit.v"           
`include "complimentNegNums.v"     
`include "mux.v"   
`include "mux32.v"   
`include "adder.v"          
        
//Assembling the top level CPU using bottom level modules

module cpu (
    PC,           // 1: Program Counter (output to instruction memory)
    INSTRUCTION,  // 2: Instruction fetched from instruction memory
    CLK,          // 3: Clock signal
    RESET,        // 4: Reset signal
    READ_S,       // 5: Read signal to cache   
    WRITE_S,      // 6: Write signal to cache       
    ADDRESS,      // 7: Address sent to cache
    WRITEDATA,    // 8: Data to be written to cache
    READDATA,     // 9: Data read from cache
    BUSYWAIT_D,    //10: Busywait signal from data cache
	BUSYWAIT_I	  //11: Busywait signal from instruction cache
);

	//Refer to the Figure 3 of instruction sheet for better clarity

	//Defining the inputs and outputs from the CPU	

    input [31:0] INSTRUCTION;     
    input CLK, RESET;      
    output reg [31:0] PC;

	//Defining the connection for Data Memory

	input BUSYWAIT_D, BUSYWAIT_I;
	input [7:0] READDATA;
	output READ_S, WRITE_S;
	output reg [7:0] WRITEDATA, ADDRESS;
 	
	//Wires used to connect ALU to Control Unit and Register
	
 	wire [7:0] ALURESULT;
    wire [2:0] ALUOP;             
	wire ZERO_OUT;	

	//Wires connected to Register Unit
	
   	wire [2:0] READREG1, READREG2, WRITEREG;  
    wire [7:0] REGOUT1, REGOUT2; 
    wire WRITEENABLE;
	wire BUSYWAIT;
	
	assign BUSYWAIT = BUSYWAIT_D | BUSYWAIT_I ; //If either of cache are busy, this is 1

 	//Wires connected to MUX1 with inputs from 2's complement and READREG2

    wire [7:0] MUX1_OUT, NEGATIVE_NUM; 
    wire MUX1SELECT;

    //Wires connected to MUX2 with inputs from IMMEDIATE and MUX1_OUT

    wire [7:0] MUX2_OUT, IMMEDIATE; 
    wire MUX2SELECT;     
	
	//Jump and branch instructions implementation

	wire JUMPSELECT, BRANCHSELECT;
	reg MUX3SELECT, INTERMEDIATE_AND1, INTERMEDIATE_AND2;
	wire [7:0] OFFSET;
	wire [31:0] MUX3_OUT, PC_OUT, OFFSET_COUNT;	

	//Wires connected to MUX4 with inputs from READDATA and ALURESULT

    wire [7:0] MUX4_OUT; 
    wire MUX4SELECT;     
	
	//-----------------------------------------------------------------------

	//Instantiation of bottom level modules in CPU - refer Figure 3 for connections

    alu ALU(REGOUT1, MUX2_OUT, ALURESULT, ALUOP, ZERO_OUT);
	reg_file register(MUX4_OUT, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);
 
	combinationalLogic comLogic(INSTRUCTION, WRITEREG, READREG1, READREG2, IMMEDIATE, OFFSET);                      
  	controlUnit control(INSTRUCTION, MUX1SELECT, MUX2SELECT, MUX4SELECT, ALUOP, WRITEENABLE, JUMPSELECT, BRANCHSELECT, WRITE_S, READ_S, BUSYWAIT_D);        
	twosComplement complement (REGOUT2, NEGATIVE_NUM);      
                                           
	mux mux1(REGOUT2, NEGATIVE_NUM, MUX1SELECT,MUX1_OUT);            
	mux mux2(IMMEDIATE, MUX1_OUT, MUX2SELECT, MUX2_OUT);
	mux32 mux3(PC_OUT, OFFSET_COUNT, MUX3SELECT, MUX3_OUT);
	mux mux4(ALURESULT, READDATA, MUX4SELECT, MUX4_OUT);

	pc_adder PCadder(PC, BUSYWAIT, PC_OUT);  
	offset_adder OffsetAdder(PC_OUT,OFFSET,OFFSET_COUNT); 

	//-----------------------------------------------------------------------    

	always @(*)
	begin

		//Building connection for Data Memory
		WRITEDATA = REGOUT1;
		ADDRESS = ALURESULT;	

		 INTERMEDIATE_AND1 = BRANCHSELECT & ZERO_OUT & ~JUMPSELECT;

		 INTERMEDIATE_AND2 = ~ZERO_OUT & JUMPSELECT;

		 MUX3SELECT = INTERMEDIATE_AND1 | INTERMEDIATE_AND2;

    end

	//Programme Counter gets updated every positive edge of clock

    always @(posedge CLK)
    begin
		
		if(RESET == 1)

		//If RESET == 1, programme counter goes to 0
			begin
            	#1 PC <= 0;
            end 
		else 

		//Adder unit for programme counter, at every positive clock edge, counter increases by 4
		//Each instructions is of 4 bytes, which is why +4

        #1 PC <= MUX3_OUT;
    end

endmodule
