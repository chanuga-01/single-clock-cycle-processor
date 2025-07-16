// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU with Forward & Reverse Jump

`include "cpu.v"
`include "dcache.v" 
`include "dmem.v"      
`include "icache.v"
`include "imem.v"


`timescale 1ns / 100ps

module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;

    // 1KB instruction memory
    reg [7:0] instr_mem [1023:0];

    //wires connected to cache
    wire C_BUSY_WAIT , C_WRITE, C_READ   ;
    wire[7:0] ADDRESS, REGOUT1, READ_DATA ;
	
    //wires connect to data memory
    wire[5:0] M_ADDRESS_OUT;
    wire M_WRITE, M_READ ;
    wire[31:0] M_WRITEDATA, M_READDATA ;

    // wire READ_IN ;
    wire[9:0] ADDRESS_IN ;

    // assign READ_IN = 1 ;


data_memory dmem (
    CLK,            // 1: Clock signal
    RESET,          // 2: Reset signal
    M_READ,         // 3: Read signal from cache to memory
    M_WRITE,        // 4: Write signal from cache to memory
    M_ADDRESS_OUT,  // 5: Address from cache to memory
    M_WRITEDATA,    // 6: Data to be written to memory (from cache)
    M_READDATA,     // 7: Data read from memory (to cache)
    BUSYWAIT_IN     // 8: Busywait signal from memory to cache
);


cpu mycpu (
    PC,            // 1: Program Counter (output to instruction memory)
    INSTRUCTION,   // 2: Instruction from instruction memory
    CLK,           // 3: Clock signal
    RESET,         // 4: Reset signal
    C_READ,        // 5: Read signal from CPU to cache
    C_WRITE,       // 6: Write signal from CPU to cache
    ADDRESS,       // 7: Address from CPU to cache
    REGOUT1,       // 8: Data from register (to be written)
    READ_DATA,     // 9: Data read from cache
    C_BUSY_WAIT,    //10: Busywait signal from cache to CPU
    ic_busywait    // 11 : from instructon 
);


cache cache1 (
    CLK,            // 1: Clock signal
    RESET,          // 2: Reset signal
    C_READ,         // 3: Read signal from CPU to cache
    C_WRITE,        // 4: Write signal from CPU to cache
    ADDRESS,        // 5: Address from CPU
    REGOUT1,        // 6: Data from CPU (write data)
    READ_DATA,      // 7: Data sent from cache to CPU (read result)

    M_READDATA,     // 8: Data read from memory
    M_WRITE,        // 9: Write signal to memory
    M_READ,         //10: Read signal to memory
    M_ADDRESS_OUT,  //11: Address sent to memory
    M_WRITEDATA,    //12: Data sent to memory for writing
    C_BUSY_WAIT,    //13: Busywait signal sent to CPU
    BUSYWAIT_IN     //14: Busywait signal from memory
);

// for instruction

icache icache1(
    CLK,           // 1: Clock signal
    RESET,           // 2: Active-high reset signal
    PC,      // 4: CPU address input
    INSTRUCTION,    // 5: Instruction output from cache to CPU

    readinst,     // 6: Instruction coming from memory to cache
    CM_READ_OUT,         // 7: Cache initiating read to memory
    CM_ADDRESS_OUT,     // 8: Address to send to memory
    ic_busywait,    // 9: Cache busywait signal to CPU
    im_busywait      // 10; Cache busywait signal from Instruction Memory
);


instruction_memory imem ( 	
    CLK,          // 1 - Clock signal
    CM_READ_OUT,           // 2 - Read signal from instruction cache
    CM_ADDRESS_OUT,   // 3 - Address from instruction cache
    readinst,       // 4 - Instruction data to instruction cache
    im_busywait        // 5 - Busywait signal to instruction cache
);

wire ic_busywait ;
wire im_busywait ;
wire[127:0] readinst ;
wire[5:0] CM_ADDRESS_OUT;
wire CM_READ_OUT ; 


    // Instantiate CPU
    initial begin
        RESET = 1;
        #5
        RESET = 0 ;
    end

    integer i,J,k,E;

    initial begin
        $dumpfile("cpu_wavedata.vcd");
        $dumpvars(0, cpu_tb);
        for (i = 0; i < 8; i = i + 1)
            $dumpvars(1, cpu_tb.mycpu.register.registers[i]);
    end


    initial begin
        $dumpfile("cpu_wavedata.vcd");
        $dumpvars(0, cpu_tb);
        for (J = 0; J < 256; J = J + 1)
            $dumpvars(1, cpu_tb.dmem.memory_array[J]);
    end

    initial begin
        $dumpfile("cpu_wavedata.vcd");
        $dumpvars(0, cpu_tb);
        for (E = 0; E < 8; E = E + 1)
            $dumpvars(1, cpu_tb.icache1.icache_array[E]);
    end

    initial begin
        $dumpfile("cpu_wavedata.vcd");
        $dumpvars(0, cpu_tb);
        for (k = 0; k < 8; k = k + 1)
            $dumpvars(1, cpu_tb.cache1.cache_array[k]);
    end

    // Clock generator
    initial begin
        CLK = 1'b0;
        forever #4 CLK = ~CLK;
    end

    // Control simulation
    initial begin
        RESET = 1'b1;
        #5 RESET = 1'b0;

        #2500 $finish;
    end

endmodule