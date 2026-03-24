module DataPath(
    input wire clock, clear,

    // Phase 2: Select and Encode Control Signals
    input wire Gra, Grb, Grc,
    input wire Rin_ctrl, Rout_ctrl, BAout,

    // Phase 1 & 2: Datapath Control Signals
    input wire PCin, PCout, IncPC, IRin, Yin, Zin, HIin, LOin, MARin, MDRin, MDRout, 
    input wire Read, Write, 
    input wire Zhighout, Zlowout, HIout, LOout, 
    input wire InPortout, Cout,
    input wire [4:0] ALU_op,

    // Phase 2: Branching and I/O Control Signals
    input wire CONin,
    input wire OutPortin,
    input wire InPortin, // Strobe for input port
    input wire [31:0] in_port_data, // External data coming into CPU
    output wire [31:0] out_port_data, // External data leaving CPU
    output wire CON_out, // Condition flag for branches

    output wire [31:0] BusMuxOut_out // Output for observation
);
    wire [31:0] BusMuxOut;
    wire [31:0] R_data [0:15];
    wire [31:0] Y_data, HI_data, LO_data, PC_data, MDR_data, MAR_data, IR_data;
    wire [31:0] InPort_data, C_sign_extended;
    wire [63:0] Z_data, ALU_out, Z_in;
    wire [31:0] PC_inc;
    wire [31:0] Mdatain;

    // Encoded control buses
    wire [15:0] Rin_bus;
    wire [15:0] Rout_bus;

    // Phase 2: Select and Encode Instantiation
    select_and_encode sel_enc (
        .IR(IR_data), .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .Rin(Rin_ctrl), .Rout(Rout_ctrl), .BAout(BAout), .Cout(Cout),
        .Rin_bus(Rin_bus), .Rout_bus(Rout_bus), .C_bus(C_sign_extended)
    );

    // Phase 2: REVISION TO R0
    wire [31:0] R0_reg_out;
    register R0(.clear(clear), .clock(clock), .enable(Rin_bus[0]), .BusMuxOut(BusMuxOut), .BusMuxIn(R0_reg_out));
    assign R_data[0] = R0_reg_out & {32{~BAout}}; // Gates 0s onto bus if BAout is high

    // Standard Registers
    register R1(.clear(clear), .clock(clock), .enable(Rin_bus[1]),  .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[1]));
    register R2(.clear(clear), .clock(clock), .enable(Rin_bus[2]),  .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[2]));
    register R3(.clear(clear), .clock(clock), .enable(Rin_bus[3]),  .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[3]));
    register R4(.clear(clear), .clock(clock), .enable(Rin_bus[4]),  .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[4]));
    register R5(.clear(clear), .clock(clock), .enable(Rin_bus[5]),  .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[5]));
    register R6(.clear(clear), .clock(clock), .enable(Rin_bus[6]),  .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[6]));
    register R7(.clear(clear), .clock(clock), .enable(Rin_bus[7]),  .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[7]));
    register R8(.clear(clear), .clock(clock), .enable(Rin_bus[8]),  .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[8]));
    register R9(.clear(clear), .clock(clock), .enable(Rin_bus[9]),  .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[9]));
    register R10(.clear(clear), .clock(clock), .enable(Rin_bus[10]), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[10]));
    register R11(.clear(clear), .clock(clock), .enable(Rin_bus[11]), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[11]));
    register R12(.clear(clear), .clock(clock), .enable(Rin_bus[12]), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[12]));
    register R13(.clear(clear), .clock(clock), .enable(Rin_bus[13]), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[13]));
    register R14(.clear(clear), .clock(clock), .enable(Rin_bus[14]), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[14]));
    register R15(.clear(clear), .clock(clock), .enable(Rin_bus[15]), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[15]));

    assign PC_inc = PC_data + 32'd1;
    assign Z_in = IncPC ? {32'b0, PC_inc} : ALU_out;

    // Dedicated registers
    register #(.DATA_WIDTH(64)) Z(.clear(clear), .clock(clock), .enable(Zin), .BusMuxOut(Z_in), .BusMuxIn(Z_data));
    register Y(.clear(clear), .clock(clock), .enable(Yin), .BusMuxOut(BusMuxOut), .BusMuxIn(Y_data));
    register PC(.clear(clear), .clock(clock), .enable(PCin), .BusMuxOut(BusMuxOut), .BusMuxIn(PC_data));
    register HI(.clear(clear), .clock(clock), .enable(HIin), .BusMuxOut(BusMuxOut), .BusMuxIn(HI_data));
    register LO(.clear(clear), .clock(clock), .enable(LOin), .BusMuxOut(BusMuxOut), .BusMuxIn(LO_data));
    register MAR(.clear(clear), .clock(clock), .enable(MARin), .BusMuxOut(BusMuxOut), .BusMuxIn(MAR_data));
    register IR(.clear(clear), .clock(clock), .enable(IRin), .BusMuxOut(BusMuxOut), .BusMuxIn(IR_data));

    // Phase 2: I/O Ports
    register InPort(.clear(clear), .clock(clock), .enable(InPortin), .BusMuxOut(in_port_data), .BusMuxIn(InPort_data));
    register OutPort(.clear(clear), .clock(clock), .enable(OutPortin), .BusMuxOut(BusMuxOut), .BusMuxIn(out_port_data));

    // Phase 2: CON FF Logic
    con_ff branch_logic(
        .clear(clear),
        .clock(clock),
        .CONin(CONin),
        .IR_C2(IR_data[20:19]),
        .BusMuxOut(BusMuxOut),
        .CON(CON_out)
    );

    // MDR Unit
    mdr_unit mdr(.clear(clear), .clock(clock), .MDRin(MDRin), .Read(Read), .BusMuxOut(BusMuxOut), .Mdatain(Mdatain), .BusMuxInMDR(MDR_data));

    // Phase 2: Memory Subsystem
    ram memory_unit(.clk(clock), .read(Read), .write(Write), .address(MAR_data[8:0]), .data_in(MDR_data), .data_out(Mdatain));

    // ALU
    ALU alu_inst(.A(Y_data), .B(BusMuxOut), .ALU_op(ALU_op), .C(ALU_out));

    // Bus using encoded Rout signals
    Bus bus_inst(
        .BusMuxInR0(R_data[0]), .BusMuxInR1(R_data[1]), .BusMuxInR2(R_data[2]), .BusMuxInR3(R_data[3]),
        .BusMuxInR4(R_data[4]), .BusMuxInR5(R_data[5]), .BusMuxInR6(R_data[6]), .BusMuxInR7(R_data[7]),
        .BusMuxInR8(R_data[8]), .BusMuxInR9(R_data[9]), .BusMuxInR10(R_data[10]), .BusMuxInR11(R_data[11]),
        .BusMuxInR12(R_data[12]), .BusMuxInR13(R_data[13]), .BusMuxInR14(R_data[14]), .BusMuxInR15(R_data[15]),
        .BusMuxInHI(HI_data), .BusMuxInLO(LO_data),
        .BusMuxInZhigh(Z_data[63:32]), .BusMuxInZlow(Z_data[31:0]),
        .BusMuxInPC(PC_data), .BusMuxInMDR(MDR_data), .BusMuxInInPort(InPort_data),
        .C_sign_extended(C_sign_extended),

        .R0out(Rout_bus[0]),  .R1out(Rout_bus[1]),  .R2out(Rout_bus[2]),  .R3out(Rout_bus[3]),
        .R4out(Rout_bus[4]),  .R5out(Rout_bus[5]),  .R6out(Rout_bus[6]),  .R7out(Rout_bus[7]),
        .R8out(Rout_bus[8]),  .R9out(Rout_bus[9]),  .R10out(Rout_bus[10]), .R11out(Rout_bus[11]),
        .R12out(Rout_bus[12]), .R13out(Rout_bus[13]), .R14out(Rout_bus[14]), .R15out(Rout_bus[15]),
        
        // BAout removed from here as it's now handled by the R0 masking logic directly
        .HIout(HIout), .LOout(LOout), .Zhighout(Zhighout), .Zlowout(Zlowout),
        .PCout(PCout), .MDRout(MDRout), .InPortout(InPortout), .Cout(Cout),
        .BusMuxOut(BusMuxOut)
    );

    assign BusMuxOut_out = BusMuxOut;
endmodule