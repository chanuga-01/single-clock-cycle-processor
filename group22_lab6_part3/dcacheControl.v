/*
Module  : Data Cache 
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description	:

This file presents a skeleton implementation of the cache controller using a Finite State Machine model. Note that this code is not complete.
*/

`timescale 1ns / 100ps

module cacheControl (
    read,                   // 1: Cache Read Signal
    write,                  // 2: Cache Write Signal
    mem_read,               // 3: Memory read enable signal
    mem_write,              // 4: Memory write enable signal
    mem_busywait,           // 5: Busywait signal from Data Memory
    hit,                    // 6: Indicates if cache hit
    dirty,                  // 7: Indicates if cache line is dirty
    address_select,         // 8: Selects whether currenct cache address or new block adddress to send to mem
    busywait,               // 9: Busywait signal to CPU
    clock,                  // 10: clock
    reset                   // 11: reset
);

    input read, write;
    input clock, reset, mem_busywait;
    input hit, dirty;
    output reg mem_read, mem_write;
    output reg busywait;
    output reg address_select;

    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001, MEM_WRITE = 3'b010;
    reg [2:0] state, next_state;

    // Finite State Memory Logic: Explained in the FSM Diagram in Assignment
    always @(*)
    begin
        case (state)
            IDLE:
                if ((read || write) && !dirty && !hit)  
                    next_state = MEM_READ;
                else if ((read || write) && dirty && !hit)
                    next_state = MEM_WRITE;
                else
                    next_state = IDLE;
            
            MEM_READ:   
                if (!mem_busywait)
                    next_state = IDLE;
                else if (mem_busywait)    
                    next_state = MEM_READ;
                else if ((!read && write) && !dirty && !hit ) 
                    next_state = MEM_WRITE ;

            MEM_WRITE:
                if (!mem_busywait)
                    next_state = MEM_READ;
                else if (mem_busywait)    
                    next_state = MEM_WRITE;
                else if ( (read && !write) && dirty && !hit )
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
                mem_write = 0;          // Write signal
                address_select = 0;     // Default to new block address
                #1
                busywait = 0;           // Memory is not being accessed
            end
         
            MEM_READ:
            begin
                mem_read = 1;           // Read signal
                mem_write = 0;          // Write signal
                address_select = 0;     // Reading new blcok from memory
                busywait = 1;           // Cache is busy with memory access
            end

            MEM_WRITE:
            begin
                mem_read = 0;           // Read signal
                mem_write = 1;          // Write signal
                address_select = 1;     // Writing the current block to memory
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