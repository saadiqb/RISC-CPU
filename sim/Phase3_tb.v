`timescale 1ns/10ps

module Phase3_tb;

    reg clock;
    reg reset;
    reg stop;
    reg [31:0] in_port_data;
    wire [31:0] out_port_data;
    wire [31:0] BusMuxOut_out;

    // Instantiate Top-Level CPU
    cpu DUT (
        .clock(clock),
        .reset(reset),
        .stop(stop),
        .in_port_data(in_port_data),
        .out_port_data(out_port_data),
        .BusMuxOut_out(BusMuxOut_out)
    );

    // Clock Generation (Period = 20ns)
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    // Simulation Sequence
    initial begin
        // Memory Initilization
        DUT.datapath_inst.memory_unit.memory[9'h089] = 32'h000000A7;
        DUT.datapath_inst.memory_unit.memory[9'h0A3] = 32'h00000068;

        
        // --- Initialization & Setup ---
        DUT.datapath_inst.memory_unit.memory[9'h000] = 32'h8A800043; // ldi R5, 0x43
        DUT.datapath_inst.memory_unit.memory[9'h001] = 32'h8AA80006; // ldi R5, 6(R5)
        DUT.datapath_inst.memory_unit.memory[9'h002] = 32'h82000089; // ld  R4, 0x89
        DUT.datapath_inst.memory_unit.memory[9'h003] = 32'h8A200004; // ldi R4, 4(R4)
        DUT.datapath_inst.memory_unit.memory[9'h004] = 32'h8027FFF8; // ld  R0, -8(R4)
        DUT.datapath_inst.memory_unit.memory[9'h005] = 32'h89000004; // ldi R2, 4
        DUT.datapath_inst.memory_unit.memory[9'h006] = 32'h8A800087; // ldi R5, 0x87
        
        // --- Branching Test 1 ---
        DUT.datapath_inst.memory_unit.memory[9'h007] = 32'hAA980003; // brmi R5, 3 (Will not branch)
        DUT.datapath_inst.memory_unit.memory[9'h008] = 32'h8AA80005; // ldi R5, 5(R5)
        DUT.datapath_inst.memory_unit.memory[9'h009] = 32'h80AFFFFD; // ld  R1, -3(R5)
        DUT.datapath_inst.memory_unit.memory[9'h00A] = 32'hD0000000; // nop
        
        // --- Branching Test 2 ---
        DUT.datapath_inst.memory_unit.memory[9'h00B] = 32'hA8900002; // brpl R1, 2 (Will branch to target)
        DUT.datapath_inst.memory_unit.memory[9'h00C] = 32'h89A80007; // ldi R3, 7(R5) (Skipped)
        DUT.datapath_inst.memory_unit.memory[9'h00D] = 32'h8B9FFFFC; // ldi R7, -4(R3) (Skipped)
        
        // --- Target: ALU Operations ---
        DUT.datapath_inst.memory_unit.memory[9'h00E] = 32'h03A90000; // add  R7, R5, R2
        DUT.datapath_inst.memory_unit.memory[9'h00F] = 32'h48880003; // addi R1, R1, 3
        DUT.datapath_inst.memory_unit.memory[9'h010] = 32'h70880000; // neg  R1, R1
        DUT.datapath_inst.memory_unit.memory[9'h011] = 32'h78880000; // not  R1, R1\
        DUT.datapath_inst.memory_unit.memory[9'h012] = 32'h5088000F; // andi R1, R1, 0xF
        DUT.datapath_inst.memory_unit.memory[9'h013] = 32'h3A010000; // ror  R4, R0, R2
        DUT.datapath_inst.memory_unit.memory[9'h014] = 32'h58A00005; // ori  R1, R4, 5
        DUT.datapath_inst.memory_unit.memory[9'h015] = 32'h2A090000; // shra R4, R1, R2
        DUT.datapath_inst.memory_unit.memory[9'h016] = 32'h22A90000; // shr  R5, R5, R2
        
        // --- Memory Operations ---
        DUT.datapath_inst.memory_unit.memory[9'h017] = 32'h928000A3; // st   0xA3, R5
        DUT.datapath_inst.memory_unit.memory[9'h018] = 32'h42810000; // rol  R5, R0, R2
        DUT.datapath_inst.memory_unit.memory[9'h019] = 32'h1B900000; // or   R7, R2, R0
        DUT.datapath_inst.memory_unit.memory[9'h01A] = 32'h12280000; // and  R4, R5, R0
        DUT.datapath_inst.memory_unit.memory[9'h01B] = 32'h93A00089; // st   0x89(R4), R7
        DUT.datapath_inst.memory_unit.memory[9'h01C] = 32'h082B8000; // sub  R0, R5, R7
        DUT.datapath_inst.memory_unit.memory[9'h01D] = 32'h32290000; // shl  R4, R5, R2
        
        // --- Multiply & Divide Setup ---
        DUT.datapath_inst.memory_unit.memory[9'h01E] = 32'h8B800007; // ldi  R7, 7
        DUT.datapath_inst.memory_unit.memory[9'h01F] = 32'h89800019; // ldi  R3, 0x19
        DUT.datapath_inst.memory_unit.memory[9'h020] = 32'h69B80000; // mul  R3, R7
        DUT.datapath_inst.memory_unit.memory[9'h021] = 32'hC0800000; // mfhi R1
        DUT.datapath_inst.memory_unit.memory[9'h022] = 32'hCB000000; // mflo R6
        DUT.datapath_inst.memory_unit.memory[9'h023] = 32'h61B80000; // div  R3, R7
        
        // --- Procedure Setup ---
        DUT.datapath_inst.memory_unit.memory[9'h024] = 32'h8C380002; // ldi  R8,  2(R7)
        DUT.datapath_inst.memory_unit.memory[9'h025] = 32'h8C9FFFFC; // ldi  R9, -4(R3)
        DUT.datapath_inst.memory_unit.memory[9'h026] = 32'h8D300003; // ldi  R10, 3(R6)
        DUT.datapath_inst.memory_unit.memory[9'h027] = 32'h8D880005; // ldi  R11, 5(R1)
        
        // --- Jump and Link (Procedure Call) ---
        DUT.datapath_inst.memory_unit.memory[9'h028] = 32'h9E500000; // jal  R12, R10
        
        // --- Halt (End of Program Return Point) ---
        DUT.datapath_inst.memory_unit.memory[9'h029] = 32'hD8000000; // halt

        // =================================================================
        // PROCEDURE SUBA (Located at Address 0xB2)
        // =================================================================
        DUT.datapath_inst.memory_unit.memory[9'h0B2] = 32'h07450000; // add  R14, R8, R10
        DUT.datapath_inst.memory_unit.memory[9'h0B3] = 32'h0ECD8000; // sub  R13, R9, R11
        DUT.datapath_inst.memory_unit.memory[9'h0B4] = 32'h0F768000; // sub  R14, R14, R13
        DUT.datapath_inst.memory_unit.memory[9'h0B5] = 32'hA6000000; // jr   R12 (Return to 0x29)

        
        // Initialize CPU control signals
        reset = 1;
        stop = 0;
        in_port_data = 32'h00000000;
        
        #40;
        
        reset = 0;

        #20000; 

        $stop;
    end
endmodule