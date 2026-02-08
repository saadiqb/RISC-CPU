module Bus (
    input wire [31:0] BusMuxInR0, BusMuxInR1, // ... add R2-R15
    input wire [31:0] BusMuxInHI, BusMuxInLO, BusMuxInZhigh, BusMuxInZlow,
    input wire [31:0] BusMuxInPC, BusMuxInMDR, BusMuxInInPort,
    input wire [31:0] C_sign_extended,
    input wire [4:0] SelectSignal, // From 32-to-5 Encoder
    output wire [31:0] BusMuxOut
);
    // Use a large case statement or mux logic based on the SelectSignal
endmodule