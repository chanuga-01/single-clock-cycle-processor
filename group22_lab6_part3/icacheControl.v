/*
Module  : Instruction Cache 
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description	:

This file presents a skeleton implementation of the cache controller using a Finite State Machine model. Note that this code is not complete.
*/

`timescale 1ns / 100ps

module icacheControl (
    mem_read,               // 2: Memory read enable signal
    mem_busywait,           // 3: Busywait signal from Instruction Memory
    hit,                    // 4: Indicates if cache hit
    busywait,               // 5: Busywait signal to CPU
    clock,                  // 6: clock
    reset                   // 7: reset
);

    // input read;
    input clock, reset, mem_busywait;
    input hit;
    output reg mem_read;
    output reg busywait;

    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001;
    reg [2:0] state, next_state;

    // Finite State Memory Logic: Explained in the FSM Diagram in Assignment
    always @(*)
    begin
        case (state)
            IDLE:
                if (!hit)  
                    next_state = MEM_READ;
                else
                    next_state = IDLE;
            
            MEM_READ:   
                if (!mem_busywait)
                    next_state = IDLE;
                else if (mem_busywait)    
                    next_state = MEM_READ;
        endcase
    end

    //Combinational Output Logic
    always @(*)
    begin
        case(state)

            IDLE: 
            begin
                mem_read = 0;           // Read signal
                #1
                busywait = 0;           // Memory is not being accessed
            end
         
            MEM_READ:
            begin
                
                mem_read = 1;           // Read signal
                busywait = 1;           // Cache is busy with memory access
            end
        endcase
    end

    // THINK ABOUT BUSYWAIT

    //Sequential logic for state transitioning 
    always @(posedge clock or reset)
    begin
        if(reset)
            state <= IDLE;
        else
            state <= next_state;
    end
    
endmodule