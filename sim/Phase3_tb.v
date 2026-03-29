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
        
        // 1. Initialize specific memory locations
        DUT.datapath_inst.memory_unit.memory[9'h089] = 32'h000000A7;
        DUT.datapath_inst.memory_unit.memory[9'h0A3] = 32'h00000068;

        // 2. Load the Phase 3 Test Program Machine Code
        // Ensure "program.hex" is in the same directory as your simulation
        $readmemh("program.hex", DUT.datapath_inst.memory_unit.memory);

        // Initialize CPU control signals
        reset = 1;
        stop = 0;
        in_port_data = 32'h00000000;
        
        // Wait for a few clock cycles to allow the clear signal to propagate
        #40; 

        reset = 0;

        // Let the simulation run for a sufficient amount of time to execute 
        // the entire test program. Adjust this if your waveform cuts off early.
        #10000; 

        $stop;
    end
endmodule