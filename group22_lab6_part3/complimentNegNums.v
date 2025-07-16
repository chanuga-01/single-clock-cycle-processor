module twosComplement(ip_number,op_number);

    //Input defined as 'ip_number' and output as 'op_number'

    input [7:0] ip_number; 
    output [7:0] op_number; 

    //Assign output 'op_number' the complement of input 'ip_number' plus 1

    assign #1 op_number = ~ip_number + 8'b00000001;

endmodule
`timescale 1ns / 100ps