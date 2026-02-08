module Bus (
    input wire [31:0] BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR3, 
    input wire [31:0] BusMuxInR4, BusMuxInR5, BusMuxInR6, BusMuxInR7,
    input wire [31:0] BusMuxInR8, BusMuxInR9, BusMuxInR10, BusMuxInR11,
    input wire [31:0] BusMuxInR12, BusMuxInR13, BusMuxInR14, BusMuxInR15,
    input wire [31:0] BusMuxInHI, BusMuxInLO, BusMuxInZhigh, BusMuxInZlow,
    input wire [31:0] BusMuxInPC, BusMuxInMDR, BusMuxInInPort,
    input wire [31:0] C_sign_extended,
    // Control signals from Control Unit (Phase 3) or Testbench (Phase 1)
    input wire R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out,
    input wire R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out,
    input wire HIout, LOout, Zhighout, Zlowout, PCout, MDRout, InPortout, Cout,
    output reg [31:0] BusMuxOut
);
    wire [4:0] SelectSignal;

    // 32-to-5 Encoder Logic
    assign SelectSignal = R0out ? 5'd0 : R1out ? 5'd1 : R2out ? 5'd2 : R3out ? 5'd3 :
                          R4out ? 5'd4 : R5out ? 5'd5 : R6out ? 5'd6 : R7out ? 5'd7 :
                          R8out ? 5'd8 : R9out ? 5'd9 : R10out ? 5'd10 : R11out ? 5'd11 :
                          R12out ? 5'd12 : R13out ? 5'd13 : R14out ? 5'd14 : R15out ? 5'd15 :
                          HIout ? 5'd16 : LOout ? 5'd17 : Zhighout ? 5'd18 : Zlowout ? 5'd19 :
                          PCout ? 5'd20 : MDRout ? 5'd21 : InPortout ? 5'd22 : Cout ? 5'd23 : 5'd0;

    // 32:1 Multiplexer
    always @(*) begin
        case(SelectSignal)
            5'd0: BusMuxOut = BusMuxInR0;
            5'd1: BusMuxOut = BusMuxInR1;
            5'd2: BusMuxOut = BusMuxInR2;
            5'd3: BusMuxOut = BusMuxInR3;
            5'd4: BusMuxOut = BusMuxInR4;
            5'd5: BusMuxOut = BusMuxInR5;
            5'd6: BusMuxOut = BusMuxInR6;
            5'd7: BusMuxOut = BusMuxInR7;
            5'd8: BusMuxOut = BusMuxInR8;
            5'd9: BusMuxOut = BusMuxInR9;
            5'd10: BusMuxOut = BusMuxInR10;
            5'd11: BusMuxOut = BusMuxInR11;
            5'd12: BusMuxOut = BusMuxInR12;
            5'd13: BusMuxOut = BusMuxInR13;
            5'd14: BusMuxOut = BusMuxInR14;
            5'd15: BusMuxOut = BusMuxInR15;
            5'd16: BusMuxOut = BusMuxInHI;
            5'd17: BusMuxOut = BusMuxInLO;
            5'd18: BusMuxOut = BusMuxInZhigh;
            5'd19: BusMuxOut = BusMuxInZlow;
            5'd20: BusMuxOut = BusMuxInPC;
            5'd21: BusMuxOut = BusMuxInMDR;
            5'd22: BusMuxOut = BusMuxInInPort;
            5'd23: BusMuxOut = C_sign_extended;
            default: BusMuxOut = 32'b0;
        endcase
    end
endmodule