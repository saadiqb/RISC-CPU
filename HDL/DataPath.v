module DataPath(
    input wire clock, clear,
    // Control signals for all 16 registers and dedicated registers
    input wire R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in,
    input wire R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in,
    input wire R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out,
    input wire R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out,
    input wire PCin, PCout, IRin, Yin, Zin, HIin, LOin, MARin, MDRin, MDRout, Read,
    input wire Zhighout, Zlowout, HIout, LOout, InPortout, Cout,
    input wire [4:0] ALU_op,
    input wire [31:0] Mdatain,
    output wire [31:0] BusMuxOut_out // Output for observation
);
    wire [31:0] BusMuxOut;
    wire [31:0] R_data [0:15];
    wire [31:0] Y_data, HI_data, LO_data, PC_data, MDR_data, MAR_data, IR_data;
    wire [31:0] InPort_data, C_sign_extended;
    wire [63:0] Z_data, ALU_out;

    assign InPort_data = 32'b0;
    assign C_sign_extended = 32'b0;

    // Instantiate R0-R15
    register R0(.clear(clear), .clock(clock), .enable(R0in), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[0]));
    register R1(.clear(clear), .clock(clock), .enable(R1in), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[1]));
    register R2(.clear(clear), .clock(clock), .enable(R2in), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[2]));
    register R3(.clear(clear), .clock(clock), .enable(R3in), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[3]));
    register R4(.clear(clear), .clock(clock), .enable(R4in), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[4]));
    register R5(.clear(clear), .clock(clock), .enable(R5in), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[5]));
    register R6(.clear(clear), .clock(clock), .enable(R6in), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[6]));
    register R7(.clear(clear), .clock(clock), .enable(R7in), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[7]));
    register R8(.clear(clear), .clock(clock), .enable(R8in), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[8]));
    register R9(.clear(clear), .clock(clock), .enable(R9in), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[9]));
    register R10(.clear(clear), .clock(clock), .enable(R10in), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[10]));
    register R11(.clear(clear), .clock(clock), .enable(R11in), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[11]));
    register R12(.clear(clear), .clock(clock), .enable(R12in), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[12]));
    register R13(.clear(clear), .clock(clock), .enable(R13in), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[13]));
    register R14(.clear(clear), .clock(clock), .enable(R14in), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[14]));
    register R15(.clear(clear), .clock(clock), .enable(R15in), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[15]));

    // Dedicated registers
    register #(.DATA_WIDTH(64)) Z(.clear(clear), .clock(clock), .enable(Zin), .BusMuxOut(ALU_out), .BusMuxIn(Z_data));
    register Y(.clear(clear), .clock(clock), .enable(Yin), .BusMuxOut(BusMuxOut), .BusMuxIn(Y_data));
    register PC(.clear(clear), .clock(clock), .enable(PCin), .BusMuxOut(BusMuxOut), .BusMuxIn(PC_data));
    register HI(.clear(clear), .clock(clock), .enable(HIin), .BusMuxOut(BusMuxOut), .BusMuxIn(HI_data));
    register LO(.clear(clear), .clock(clock), .enable(LOin), .BusMuxOut(BusMuxOut), .BusMuxIn(LO_data));
    register MAR(.clear(clear), .clock(clock), .enable(MARin), .BusMuxOut(BusMuxOut), .BusMuxIn(MAR_data));
    register IR(.clear(clear), .clock(clock), .enable(IRin), .BusMuxOut(BusMuxOut), .BusMuxIn(IR_data));
    mdr_unit mdr(.clear(clear), .clock(clock), .MDRin(MDRin), .Read(Read), .BusMuxOut(BusMuxOut), .Mdatain(Mdatain), .BusMuxInMDR(MDR_data));

    // ALU Integration
    ALU alu_inst(.A(Y_data), .B(BusMuxOut), .ALU_op(ALU_op), .C(ALU_out));

    // Bus Integration
    Bus bus_inst(
        .BusMuxInR0(R_data[0]), .BusMuxInR1(R_data[1]), .BusMuxInR2(R_data[2]), .BusMuxInR3(R_data[3]),
        .BusMuxInR4(R_data[4]), .BusMuxInR5(R_data[5]), .BusMuxInR6(R_data[6]), .BusMuxInR7(R_data[7]),
        .BusMuxInR8(R_data[8]), .BusMuxInR9(R_data[9]), .BusMuxInR10(R_data[10]), .BusMuxInR11(R_data[11]),
        .BusMuxInR12(R_data[12]), .BusMuxInR13(R_data[13]), .BusMuxInR14(R_data[14]), .BusMuxInR15(R_data[15]),
        .BusMuxInHI(HI_data), .BusMuxInLO(LO_data),
        .BusMuxInZhigh(Z_data[63:32]), .BusMuxInZlow(Z_data[31:0]),
        .BusMuxInPC(PC_data), .BusMuxInMDR(MDR_data), .BusMuxInInPort(InPort_data),
        .C_sign_extended(C_sign_extended),
        .R0out(R0out), .R1out(R1out), .R2out(R2out), .R3out(R3out), .R4out(R4out), .R5out(R5out), .R6out(R6out), .R7out(R7out),
        .R8out(R8out), .R9out(R9out), .R10out(R10out), .R11out(R11out), .R12out(R12out), .R13out(R13out), .R14out(R14out), .R15out(R15out),
        .HIout(HIout), .LOout(LOout), .Zhighout(Zhighout), .Zlowout(Zlowout),
        .PCout(PCout), .MDRout(MDRout), .InPortout(InPortout), .Cout(Cout),
        .BusMuxOut(BusMuxOut)
    );

    assign BusMuxOut_out = BusMuxOut;
endmodule