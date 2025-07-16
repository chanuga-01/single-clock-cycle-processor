module reg_file(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS, WRITE, CLK, RESET);
	
	input [7:0] IN;
	input [2:0] OUT1ADDRESS, OUT2ADDRESS, INADDRESS;
	input WRITE, CLK, RESET;
	output reg [7:0] OUT1, OUT2;

	//An array of 8 registers to store operands and results from/for ALU

	reg [7:0] registers[7:0];

	//Changes are made at the positive edge of the clock

	always @(posedge CLK)
		begin

		//If RESET = 1, then all the registers are cleared
		
		if (RESET == 1'b1) 
			begin
			
			registers[0] <= #1 8'b0;
			registers[1] <= #1 8'b0;
			registers[2] <= #1 8'b0;
			registers[3] <= #1 8'b0;
			registers[4] <= #1 8'b0;
			registers[5] <= #1 8'b0;
			registers[6] <= #1 8'b0;
			registers[7] <= #1 8'b0;
        		
			end

		//When writenable is ON, values in IN port can be written into a register file
        
        	else if (WRITE == 1'b1)
			begin
            #1		
			registers[INADDRESS] =  IN;
        
			end
		end

	
	//Reading out registers and letting them out is done in a seperate block as it should be asyncrhonous
	//Always @(posedge CLK) is for synchronous parts

	always @(*)
		begin
		
		//Non-blocking assignment because parallel data flow, otherwise 4 unit delay for OUT2
		#2
		OUT1 <= registers[OUT1ADDRESS];
		OUT2 <= registers[OUT2ADDRESS];

		end
endmodule