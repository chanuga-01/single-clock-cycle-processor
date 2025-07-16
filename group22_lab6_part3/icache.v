// `include "demux.v"
// `include "mux4x1.v"
`include "icacheControl.v"

`timescale 1ns / 100ps

module icache (
    CLOCK,           // 1: Clock signal
    RESET,           // 2: Active-high reset signal

    ADDRESS_IN,      // 4: CPU address input    is equal to pc
    READDATA_OUT,    // 5: Instruction output from cache to CPU

    READDATA_IN,     // 6: Instruction coming from memory to cache
    READ_OUT,        // 7: Cache initiating read to memory
    ADDRESS_OUT,     // 8: Address to send to memory
    BUSYWAIT_OUT,    // 9: Cache busywait signal to CPU
    BUSYWAIT_IN      // 10; Cache busywait signal from Instruction Memory
);

input CLOCK;
input RESET;
input BUSYWAIT_IN;
input [31:0] ADDRESS_IN;
input [127:0] READDATA_IN;

output READ_OUT;
output BUSYWAIT_OUT;
output [5:0] ADDRESS_OUT;
output reg [31:0] READDATA_OUT;

//Definition of internal registers
reg [2:0] INDEX;
reg [2:0] TAG;
reg [1:0] BLOCK_OFFSET;

reg VALID_BIT;
reg TAG_SIGNAL;
reg [2:0] CACHE_CURRENT_TAG;
reg [127:0] CACHE_CURRENT_DATA;
reg HIT;

reg [5:0] BLOCK_ADDRESS;

//=============================================================================================

// Declare Cache Array: 8 blocks, 132 bits each
reg [131:0] icache_array [7:0];

//Decoding the Input Address
always @(*) begin
    INDEX        = ADDRESS_IN[6:4];
    TAG          = ADDRESS_IN[9:7];
    BLOCK_OFFSET = ADDRESS_IN[3:2];
    BLOCK_ADDRESS = ADDRESS_IN[9:4] ;
end 

//Decoding the Cache Instruction
// [131] = Valid bit, [130:128] = Tag, [127:0] =  Instruction (4 words)
always @(*) begin
    #1;
    VALID_BIT         = icache_array[INDEX][131];
    CACHE_CURRENT_TAG = icache_array[INDEX][130:128];
    CACHE_CURRENT_DATA= icache_array[INDEX][127:0];
end

//=============================================================================================

//Hit or Miss Logic
always @(*) begin
    #0.9 TAG_SIGNAL = (TAG == CACHE_CURRENT_TAG) ? 1'b1 : 1'b0 ;
    HIT = TAG_SIGNAL & VALID_BIT;
end

//=============================================================================================

//HIT CASE

//Read directly from the Cache Memory
always @(*) begin
    if (HIT) begin  // removed read in
        #1;
        case (BLOCK_OFFSET)
            2'b00: READDATA_OUT = CACHE_CURRENT_DATA[31:0];     // instrction 0
            2'b01: READDATA_OUT = CACHE_CURRENT_DATA[63:32];    // instruction 1
            2'b10: READDATA_OUT = CACHE_CURRENT_DATA[95:64];   // instruction 2
            2'b11: READDATA_OUT = CACHE_CURRENT_DATA[127:96];   // instruction 3
        endcase
    end
end

// =============================================================================================

//MISS CASE

//Accessing Cache Controller
icacheControl icacheControl1 (
    // READ_IN,            // 1: Read Signal
    READ_OUT,           // 2: Tell whether Read or Write to Memory 
    BUSYWAIT_IN,        // 3: Memory Busywait Signal   
    HIT,                // 4: Cache Hit Signal
    BUSYWAIT_OUT,       // 5: Checks if Memory is being accessed
    CLOCK,              // 6: Clock
    RESET               // 7: Reset Signals
);

//Forwarding the block address to Instruction Memory
assign ADDRESS_OUT = BLOCK_ADDRESS;

//Update cache block after everything is complete
always @(posedge CLOCK or posedge RESET) begin

    if (RESET) begin
    
    //Clear the instruction, valid bit, dirty bit and tag in case of a reset
    icache_array[0] <= 132'b0;
    icache_array[1] <= 132'b0;
    icache_array[2] <= 132'b0;
    icache_array[3] <= 132'b0;
    icache_array[4] <= 132'b0;
    icache_array[5] <= 132'b0;
    icache_array[6] <= 132'b0;
    icache_array[7] <= 132'b0;

    end else begin

    //When memory is done reading the requested instruction, bring the new block into Cache
    if (!BUSYWAIT_IN && READ_OUT) begin
        #1 icache_array[INDEX][127:0]   <= READDATA_IN;      // New instruction after memory read
        icache_array[INDEX][130:128]    <= TAG;              // Update tag
        icache_array[INDEX][131]        <= 1'b1;             // Set valid bit
    end

    end
end

always @(*) begin
    if (BUSYWAIT_IN && !HIT) begin
        READDATA_OUT = ADDRESS_IN ;
        
    end
end

endmodule



