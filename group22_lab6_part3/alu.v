//LAB 05 PART 1 - GROUP 22
`timescale 1ns / 100ps
module alu(DATA1, DATA2, RESULT, SELECT, ZERO);
	
	input [7:0] DATA1, DATA2; 
	input [2:0] SELECT;
	output reg [7:0] RESULT;
	output reg ZERO;

	//Wires to store the results from each function block

	wire [7:0] add_res, and_res, or_res, forward_res, mult_res, lshift_res, ashift_res, rot_res;

	//Instantiating the function blocks and assigning the results to wires defined

	ADD add1(DATA1, DATA2, add_res);
	AND and1(DATA1, DATA2, and_res);
	OR or1(DATA1, DATA2, or_res);
	FORWARD forward1(DATA1, DATA2, forward_res);
	MULTIPLY mult1(DATA1, DATA2, mult_res);
	L_SHIFT lshift1(DATA1, DATA2, lshift_res);
	A_SHIFT ashift1(DATA1, DATA2, ashift_res);
	ROTATE rotate1(DATA1, DATA2, rot_res);
	
	
	//Implementing a MUX module to select the output based on select value

	always @(*) 
		
		begin

		ZERO = 0;				//ZERO is set to 0 by default


		if (SELECT == 3'b001) begin
			RESULT = add_res;			// MUX connects to add result wire if select is 001
			if (add_res == 8'b00000000)
				ZERO = 1;

		end else if (SELECT == 3'b010) begin
			RESULT = and_res;			// MUX connects to and result wire if select is 010

		end else if (SELECT == 3'b011) begin
			RESULT = or_res;			// MUX connects to or result wire if select is 011

		end else if (SELECT == 3'b000) begin
			RESULT = forward_res;		// MUX connects to forward result wire if select is 000	

		end else if (SELECT == 3'b100) begin
			RESULT = mult_res;			// MUX connects to multiply result wire if select is 100	

		end else if (SELECT == 3'b101) begin
			RESULT = lshift_res;		// MUX connects to logic shift result wire if select is 101	

		end else if (SELECT == 3'b110) begin
			RESULT = ashift_res;		// MUX connects to arithmetic result wire if select is 110

		end else if (SELECT == 3'b111) begin
			RESULT = rot_res;			// MUX connects to rotate result wire if select is 111		
		end
		
		end

endmodule

// Module for addition operation
module ADD(DATA1, DATA2, RESULT);

	input [7:0] DATA1, DATA2;
	output reg [7:0] RESULT;

	// Result is sum of DATA2 and DATA1
	always @(*) begin
		#2 RESULT = DATA1 + DATA2;
	end

endmodule

// Module for bitwise AND operation
module AND(DATA1, DATA2, RESULT);

	input [7:0] DATA1, DATA2;
	output reg [7:0] RESULT;

	// Result is bitwise AND of DATA2 and DATA1
	always @(*) begin
		#1 RESULT = DATA1 & DATA2;
	end

endmodule

// Module for bitwise OR operation
module OR(DATA1, DATA2, RESULT);

	input [7:0] DATA1, DATA2;
	output reg [7:0] RESULT;

	// Result is bitwise OR of DATA2 and DATA1
	always @(*) begin
		#1 RESULT = DATA1 | DATA2;
	end

endmodule

// Module for forwarding operation
module FORWARD(DATA1, DATA2, RESULT);

	input [7:0] DATA1, DATA2;
	output reg [7:0] RESULT;

	// Result is equal to DATA2
	always @(*) begin
		#1 RESULT = DATA2;
	end

endmodule


//Module for multiplication operation
module MULTIPLY(DATA1, DATA2, RESULT);

	input [7:0] DATA1, DATA2;
	output [7:0] RESULT;
	
	//Carry bits for intermediate sums
	wire C0 [5:0];
	wire C1 [4:0];
	wire C2 [3:0];
	wire C3 [2:0];
	wire C4 [1:0];
	wire C5;
	
	//Intermediate sums
	wire sum0 [5:0];
	wire sum1 [4:0];
	wire sum2 [3:0];
	wire sum3 [2:0];
	wire sum4 [1:0];
	wire sum5, dummy_carry;
	
	// To store result before output
	wire [7:0] OUT;
	
	//First bit of RESULT can be directly set
	assign OUT[0] = DATA2[0] & DATA1[0];	
	
	//Full Adder layers to calculate the result by shifting and adding
	//Layer 0
	full_adder_module FA0_0(DATA2[0] & DATA1[1], DATA2[1] & DATA1[0], 1'b0, OUT[1], C0[0]);
	full_adder_module FA0_1(DATA2[0] & DATA1[2], DATA2[1] & DATA1[1], C0[0], sum0[0], C0[1]);
	full_adder_module FA0_2(DATA2[0] & DATA1[3], DATA2[1] & DATA1[2], C0[1], sum0[1], C0[2]);
	full_adder_module FA0_3(DATA2[0] & DATA1[4], DATA2[1] & DATA1[3], C0[2], sum0[2], C0[3]);
	full_adder_module FA0_4(DATA2[0] & DATA1[5], DATA2[1] & DATA1[4], C0[3], sum0[3], C0[4]);
	full_adder_module FA0_5(DATA2[0] & DATA1[6], DATA2[1] & DATA1[5], C0[4], sum0[4], C0[5]);
	full_adder_module FA0_6(DATA2[0] & DATA1[7], DATA2[1] & DATA1[6], C0[5], sum0[5],dummy_carry );
	
	//Layer 1
	full_adder_module FA1_0(sum0[0], DATA2[2] & DATA1[0], 1'b0, OUT[2], C1[0]);
	full_adder_module FA1_1(sum0[1], DATA2[2] & DATA1[1], C1[0], sum1[0], C1[1]);
	full_adder_module FA1_2(sum0[2], DATA2[2] & DATA1[2], C1[1], sum1[1], C1[2]);
	full_adder_module FA1_3(sum0[3], DATA2[2] & DATA1[3], C1[2], sum1[2], C1[3]);
	full_adder_module FA1_4(sum0[4], DATA2[2] & DATA1[4], C1[3], sum1[3], C1[4]);
	full_adder_module FA1_5(sum0[5], DATA2[2] & DATA1[5], C1[4], sum1[4],dummy_carry );
	
	//Layer 2
	full_adder_module FA2_0(sum1[0], DATA2[3] & DATA1[0], 1'b0, OUT[3], C2[0]);
	full_adder_module FA2_1(sum1[1], DATA2[3] & DATA1[1], C2[0], sum2[0], C2[1]);
	full_adder_module FA2_2(sum1[2], DATA2[3] & DATA1[2], C2[1], sum2[1], C2[2]);
	full_adder_module FA2_3(sum1[3], DATA2[3] & DATA1[3], C2[2], sum2[2], C2[3]);
	full_adder_module FA2_4(sum1[4], DATA2[3] & DATA1[4], C2[3], sum2[3], dummy_carry);
	
	//Layer 3
	full_adder_module FA3_0(sum2[0], DATA2[4] & DATA1[0], 1'b0, OUT[4], C3[0]);
	full_adder_module FA3_1(sum2[1], DATA2[4] & DATA1[1], C3[0], sum3[0], C3[1]);
	full_adder_module FA3_2(sum2[2], DATA2[4] & DATA1[2], C3[1], sum3[1], C3[2]);
	full_adder_module FA3_3(sum2[3], DATA2[4] & DATA1[3], C3[2], sum3[2], dummy_carry);
	
	//Layer 4
	full_adder_module FA4_0(sum3[0], DATA2[5] & DATA1[0], 1'b0, OUT[5], C4[0]);
	full_adder_module FA4_1(sum3[1], DATA2[5] & DATA1[1], C4[0], sum4[0], C4[1]);
	full_adder_module FA4_2(sum3[2], DATA2[5] & DATA1[2], C4[1], sum4[1], dummy_carry);
	
	//Layer 5
	full_adder_module FA5_0(sum4[0], DATA2[6] & DATA1[0], 1'b0, OUT[6], C5);
	full_adder_module FA5_1(sum4[1], DATA2[6] & DATA1[1], C5, sum5,dummy_carry );
	
	//Layer 6
	full_adder_module FA6_0(sum5, DATA2[7] & DATA1[0], 1'b0, OUT[7], dummy_carry);
	
	//Sending out result after 2 unit delay
	assign #2 RESULT = OUT;

endmodule


//Module for logical shift
module L_SHIFT(DATA1, DATA2, RESULT); // shift amount = data2

    input [7:0] DATA1, DATA2;
    output [7:0] RESULT;

	//We can ignore the bits [6:3] because after 7 bit shifts, all bits will be shifted out
	//DATA[7] is reserved for direction of logical shift

    wire [2:0] shift = DATA2[2:0];  // Shift amount: 0–7
    wire       dir   = DATA2[7];    // Shift direction: 1 = left, 0 = right

	//Number be will be shifted in three stages 1-2-4 bits

    wire [7:0] stage0, stage1, stage2;

    // Stage 0: shift by 1
    assign stage0 = (dir == 1) ? 
                    (shift[0] ? {DATA1[6:0], 1'b0} : DATA1) :
                    (shift[0] ? {1'b0, DATA1[7:1]} : DATA1);

    // Stage 1: shift by 2
    assign stage1 = (dir == 1) ? 
                    (shift[1] ? {stage0[5:0], 2'b00} : stage0) :
                    (shift[1] ? {2'b00, stage0[7:2]} : stage0);

    // Stage 2: shift by 4
    assign stage2 = (dir == 1) ? 
                    (shift[2] ? {stage1[3:0], 4'b0000} : stage1) :
                    (shift[2] ? {4'b0000, stage1[7:4]} : stage1);

    assign #2 RESULT = stage2;

endmodule



//Module for arithmatic right shift
module A_SHIFT(DATA1, DATA2, RESULT);  // shift amount = data2

    input [7:0] DATA1, DATA2;
    output [7:0] RESULT;

    //We can ignore the bits [6:3] because after 7 bit shifts, all bits will be shifted out

    wire [2:0] shift = DATA2[2:0];  // Shift amount 0–7
    wire sign = DATA1[7];           // Sign bit for extension

	//Number be will be shifted in three stages 1-2-4 bits

    wire [7:0] stage0, stage1, stage2;

    // Stage 0: shift by 1 with sign extension
    assign stage0 = (shift[0]) ? {sign, DATA1[7:1]} : DATA1;

    // Stage 1: shift by 2 with sign extension
    assign stage1 = (shift[1]) ? {{2{sign}}, stage0[7:2]} : stage0;

    // Stage 2: shift by 4 with sign extension
    assign stage2 = (shift[2]) ? {{4{sign}}, stage1[7:4]} : stage1;

    assign #2 RESULT = stage2;

endmodule


//Module for rotating right
module ROTATE(DATA1, DATA2, RESULT);

    input [7:0] DATA1, DATA2;
    output [7:0] RESULT;

    // Reduce rotate amount modulo 8 using lower 3 bits
    wire [2:0] rotate_amt = DATA2[2:0];

	//Number be will be shifted in three stages 1-2-4 bits
    wire [7:0] stage0, stage1, stage2;

    // Stage 0: rotate right by 1 if rotate_amt[0] == 1
    assign stage0 = (rotate_amt[0]) ? {DATA1[0], DATA1[7:1]} : DATA1;

    // Stage 1: rotate right by 2 if rotate_amt[1] == 1
    assign stage1 = (rotate_amt[1]) ? {stage0[1:0], stage0[7:2]} : stage0;

    // Stage 2: rotate right by 4 if rotate_amt[2] == 1
    assign stage2 = (rotate_amt[2]) ? {stage1[3:0], stage1[7:4]} : stage1;

    assign #2 RESULT = stage2;

endmodule


//Module for Full Adder
module full_adder_module(A, B, C, SUM, CARRY);

	//Input and output port declaration
	input A, B, C;
	output SUM, CARRY;
	
	//Combinational logic for SUM and CARRY bit outputs
	assign SUM = (A ^ B ^ C);
	assign CARRY = (A & B) | (C & (A ^ B));

endmodule



