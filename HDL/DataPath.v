module DataPath(
    input wire clock, clear,
    // Add all control signals (R0in, R0out, etc.) required by Phase 1
);
    wire [31:0] BusMuxOut;
    wire [31:0] BusMuxInR [0:15]; // Array for R0-R15 outputs
    // Instantiate registers R0-R15, PC, IR, Y, Z, HI, LO here
    // Instantiate ALU here
    // Instantiate Bus here
endmodule