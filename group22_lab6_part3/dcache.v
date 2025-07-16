// `include "demux.v"
// `include "mux4x1.v"
`include "mux6.v"
`include "dcacheControl.v"

`timescale 1ns / 100ps

module cache (
    CLOCK,           // 1: Clock signal
    RESET,           // 2: Active-high reset signal
    READ_IN,         // 3: CPU read signal
    WRITE_IN,        // 4: CPU write signal
    ADDRESS_IN,      // 5: CPU address input (e.g., [9:0])
    WRITEDATA_IN,    // 6: Data from CPU to be written into cache
    READDATA_OUT,    // 7: Data output from cache to CPU

    READDATA_IN,     // 8: Data coming from memory to cache
    WRITE_OUT,       // 9: Cache initiating write to memory
    READ_OUT,        // 10: Cache initiating read to memory
    ADDRESS_OUT,     // 11: Address to send to memory
    WRITEDATA_OUT,   // 12: Data to write on to memory
    BUSYWAIT_OUT,    // 13: Cache busywait signal to CPU
    BUSYWAIT_IN      // 14; Cache busywait signal from Data Memory
);

input CLOCK;
input RESET;
input READ_IN;
input WRITE_IN;
input BUSYWAIT_IN;
input [7:0] ADDRESS_IN;
input [7:0] WRITEDATA_IN;
input [31:0] READDATA_IN;

output READ_OUT;
output WRITE_OUT;
output BUSYWAIT_OUT;
output [5:0] ADDRESS_OUT;
output reg [7:0] READDATA_OUT;
output [31:0] WRITEDATA_OUT;

//Definition of internal registers
reg [2:0] INDEX;
reg [2:0] TAG;
reg [1:0] BLOCK_OFFSET;

reg VALID_BIT;
reg DIRTY_BIT;
reg TAG_SIGNAL;
reg [2:0] CACHE_CURRENT_TAG;
reg [31:0] CACHE_CURRENT_DATA;
reg HIT;
wire ADDRESS_SELECT;

reg [5:0] BLOCK_ADDRESS;
reg [5:0] CACHE_CURRENT_BLOCK_ADDRESS;

reg WRITE_HIT;
reg [31:0] new_cache_data;

//=============================================================================================

// Declare Cache Array: 8 blocks, 39 bits each
reg [36:0] cache_array [7:0];

//Decoding the Input Address
always @(*) begin
    INDEX        = ADDRESS_IN[4:2];
    TAG          = ADDRESS_IN[7:5];
    BLOCK_OFFSET = ADDRESS_IN[1:0];
    BLOCK_ADDRESS = ADDRESS_IN[7:2] ;
end 

//Decoding the Cache Data
// [36] = Valid bit, [35] = Dirty bit, [34:32] = Tag, [31:0] =  Data (4 words)
always @(*) begin
    #1;
    VALID_BIT         = cache_array[INDEX][36];
    DIRTY_BIT         = cache_array[INDEX][35];
    CACHE_CURRENT_TAG = cache_array[INDEX][34:32];
    CACHE_CURRENT_DATA= cache_array[INDEX][31:0];
    CACHE_CURRENT_BLOCK_ADDRESS = {cache_array[INDEX][34:32], INDEX};
end

//=============================================================================================

//Hit or Miss Logic
always @(*) begin
    #0.9 TAG_SIGNAL = (TAG == CACHE_CURRENT_TAG) ? 1'b1 : 1'b0 ;
    HIT = TAG_SIGNAL & VALID_BIT;
end

//=============================================================================================

//HIT CASE

//PART 1: Read directly from the Cache Memory
always @(*) begin
    if (READ_IN && HIT) begin
        #1;
        case (BLOCK_OFFSET)
            2'b00: READDATA_OUT = CACHE_CURRENT_DATA[7:0];     // Byte 0
            2'b01: READDATA_OUT = CACHE_CURRENT_DATA[15:8];    // Byte 1
            2'b10: READDATA_OUT = CACHE_CURRENT_DATA[23:16];   // Byte 2
            2'b11: READDATA_OUT = CACHE_CURRENT_DATA[31:24];   // Byte 3
        endcase
    end
end

//PART 2: Write directly on to the Cache Memory
always @(*) begin
    WRITE_HIT = WRITE_IN && HIT;

    //Initialises as current cache data - if no write happens, stays this way
    new_cache_data = CACHE_CURRENT_DATA;  

    if (WRITE_HIT) begin
        case (BLOCK_OFFSET)
            2'b00: new_cache_data[7:0]   = WRITEDATA_IN;
            2'b01: new_cache_data[15:8]  = WRITEDATA_IN;
            2'b10: new_cache_data[23:16] = WRITEDATA_IN;
            2'b11: new_cache_data[31:24] = WRITEDATA_IN;
        endcase
    end
end

// =============================================================================================

//MISS CASE

//Accessing Cache Controller
cacheControl cacheControl1 (
    READ_IN,            // 1: Read Signal
    WRITE_IN,           // 2: Write Signal
    READ_OUT,           // 3: Tell whether Read or Write to Memory 
    WRITE_OUT,          // 4: Tell whether Read or Write to Memory
    BUSYWAIT_IN,        // 5: Memory Busywait Signal   
    HIT,                // 6: Cache Hit Signal
    DIRTY_BIT,          // 7: Cache Dirty Signal
    ADDRESS_SELECT,     // 8: Selects the address to be sent to Data Memory
    BUSYWAIT_OUT,       // 9: Checks if Memory is being accessed
    CLOCK,              // 10: Clock
    RESET               // 11: Reset Signals
);

//Selecting the correct address to be sent to Data Memory
mux6 cachemux(BLOCK_ADDRESS, CACHE_CURRENT_BLOCK_ADDRESS, ADDRESS_SELECT, ADDRESS_OUT);

assign WRITEDATA_OUT = CACHE_CURRENT_DATA;

//Update cache block after everything is complete
always @(posedge CLOCK or posedge RESET) begin

    if (RESET) begin
    
    //Clear the data, valid bit, dirty bit and tag in case of a reset
    cache_array[0] <= 37'b0;
    cache_array[1] <= 37'b0;
    cache_array[2] <= 37'b0;
    cache_array[3] <= 37'b0;
    cache_array[4] <= 37'b0;
    cache_array[5] <= 37'b0;
    cache_array[6] <= 37'b0;
    cache_array[7] <= 37'b0;

    end else begin

    //When memory is done reading the requested data, bring the new blocl into Cache
    if (!BUSYWAIT_IN && READ_OUT) begin
        #1 cache_array[INDEX][31:0]   <= READDATA_IN;  // New data after memory read
        cache_array[INDEX][34:32]  <= TAG;             // Update tag
        cache_array[INDEX][36]     <= 1'b1;            // Set valid bit
        cache_array[INDEX][35]     <= 1'b0;            // Clear dirty bit
    end

    //When memory is done reading the requested data, write the data from CPU in Cache
    if (!BUSYWAIT_IN && READ_OUT && WRITE_IN) begin
        case (BLOCK_OFFSET)
            2'b00: cache_array[INDEX][7:0]    <= WRITEDATA_IN;
            2'b01: cache_array[INDEX][15:8]   <= WRITEDATA_IN;
            2'b10: cache_array[INDEX][23:16]  <= WRITEDATA_IN;
            2'b11: cache_array[INDEX][31:24]  <= WRITEDATA_IN;
        endcase
        cache_array[INDEX][35] <= 1'b1; // Set dirty bit
    end

    //If there is a write hit, update the cache with updated block in next clock cycle
    if (WRITE_HIT) begin
        #1 cache_array[INDEX][31:0]  <= new_cache_data;   // Update cache block on write hit
        cache_array[INDEX][35]    <= 1'b1;                // Set dirty bit
    end

    end
end

endmodule



