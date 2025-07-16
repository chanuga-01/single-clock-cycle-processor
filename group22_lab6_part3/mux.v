module mux(DATA1 , DATA2 , SELECT, OUTPUT);

	input [7:0] DATA1 , DATA2;  
	input SELECT;
	output reg [7:0] OUTPUT;

	always @(DATA1 , DATA2 , SELECT)
		begin
	
	//Start of combinational logic block triggered by changes in DATA1, DATA2, or SELECT

		case(SELECT)
			1'b0 : OUTPUT = DATA1; // If SELECT is 0, OUTPUT receives DATA1
			1'b1 : OUTPUT = DATA2; // If SELECT is 1, OUTPUT receives DATA2
		endcase

	end
	
endmodule

`timescale 1ns / 100ps