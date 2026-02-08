module mdr_unit(
    input wire clear, clock, MDRin, Read,
    input wire [31:0] BusMuxOut, Mdatain,
    output wire [31:0] BusMuxInMDR
);
    wire [31:0] MDMuxOut;
    
    // MDMux [cite: 248]
    assign MDMuxOut = (Read) ? Mdatain : BusMuxOut;

    // MDR Register instantiation [cite: 255]
    register mdr_reg(
        .clear(clear), 
        .clock(clock), 
        .enable(MDRin), 
        .BusMuxOut(MDMuxOut), 
        .BusMuxIn(BusMuxInMDR)
    );
endmodule