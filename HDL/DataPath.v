module DataPath(
    input wire clock, clear,
    // Phase 2 §2.2 — decoded register controls (Gra/Grb/Grc/Rin/Rout/BAout). In Phase 2 lab
    // simulation these are asserted manually from the testbench per control sequences; a control
    // unit may drive the same ports in a later phase without changing this datapath.
    input wire Gra, Grb, Grc, Rin, Rout, BAout,
    input wire PCin, PCout, IncPC, IRin, Yin, Zin, HIin, LOin, MARin, MDRin, MDRout,
    input wire Read, Write,
    input wire Zhighout, Zlowout, HIout, LOout,
    input wire InPortout, Cout,
    input wire CONin,
    // §2.5 — external input pins (switches / pads); presented to bus when InPortout
    input wire [31:0] input_port,
    input wire OutPortin,
    input wire [4:0] ALU_op,
    output wire [31:0] BusMuxOut_out,
    output wire CON_out,
    output wire [31:0] output_port
);
    wire [31:0] BusMuxOut;
    wire [31:0] R_data [0:15];
    wire [31:0] Y_data, HI_data, LO_data, PC_data, MDR_data, MAR_data, IR_data;
    wire [31:0] InPort_data, C_sign_extended;
    wire [31:0] OutPort_data;
    wire [63:0] Z_data, ALU_out, Z_in;
    wire [31:0] PC_inc;
    wire [31:0] Mdatain;
    wire [15:0] R_in_dec, R_out_dec;
    wire R0_bus_zero;
    wire [31:0] BusMuxInR0_eff;

    assign InPort_data = input_port;

    select_encode reg_decode (
        .IR(IR_data),
        .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .Rin(Rin), .Rout(Rout), .BAout(BAout),
        .R_in(R_in_dec),
        .R_out(R_out_dec),
        .C_sign_extended(C_sign_extended),
        .R0_bus_zero(R0_bus_zero)
    );

    // Phase 2 §2.3 — revised R0 to bus: BAout + R0 selected (no Rout) ⇒ 0 on bus; else R0 contents
    assign BusMuxInR0_eff = R0_bus_zero ? 32'b0 : R_data[0];

    register R0(.clear(clear), .clock(clock), .enable(R_in_dec[0]),  .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[0]));
    register R1(.clear(clear), .clock(clock), .enable(R_in_dec[1]),  .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[1]));
    register R2(.clear(clear), .clock(clock), .enable(R_in_dec[2]),  .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[2]));
    register R3(.clear(clear), .clock(clock), .enable(R_in_dec[3]),  .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[3]));
    register R4(.clear(clear), .clock(clock), .enable(R_in_dec[4]),  .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[4]));
    register R5(.clear(clear), .clock(clock), .enable(R_in_dec[5]),  .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[5]));
    register R6(.clear(clear), .clock(clock), .enable(R_in_dec[6]),  .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[6]));
    register R7(.clear(clear), .clock(clock), .enable(R_in_dec[7]),  .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[7]));
    register R8(.clear(clear), .clock(clock), .enable(R_in_dec[8]),  .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[8]));
    register R9(.clear(clear), .clock(clock), .enable(R_in_dec[9]),  .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[9]));
    register R10(.clear(clear), .clock(clock), .enable(R_in_dec[10]), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[10]));
    register R11(.clear(clear), .clock(clock), .enable(R_in_dec[11]), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[11]));
    register R12(.clear(clear), .clock(clock), .enable(R_in_dec[12]), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[12]));
    register R13(.clear(clear), .clock(clock), .enable(R_in_dec[13]), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[13]));
    register R14(.clear(clear), .clock(clock), .enable(R_in_dec[14]), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[14]));
    register R15(.clear(clear), .clock(clock), .enable(R_in_dec[15]), .BusMuxOut(BusMuxOut), .BusMuxIn(R_data[15]));

    assign PC_inc = PC_data + 32'd1;
    assign Z_in = IncPC ? {32'b0, PC_inc} : ALU_out;

    register #(.DATA_WIDTH(64)) Z(.clear(clear), .clock(clock), .enable(Zin), .BusMuxOut(Z_in), .BusMuxIn(Z_data));
    register Y(.clear(clear), .clock(clock), .enable(Yin), .BusMuxOut(BusMuxOut), .BusMuxIn(Y_data));
    register PC(.clear(clear), .clock(clock), .enable(PCin), .BusMuxOut(BusMuxOut), .BusMuxIn(PC_data));
    register HI(.clear(clear), .clock(clock), .enable(HIin), .BusMuxOut(BusMuxOut), .BusMuxIn(HI_data));
    register LO(.clear(clear), .clock(clock), .enable(LOin), .BusMuxOut(BusMuxOut), .BusMuxIn(LO_data));
    register MAR(.clear(clear), .clock(clock), .enable(MARin), .BusMuxOut(BusMuxOut), .BusMuxIn(MAR_data));
    register IR(.clear(clear), .clock(clock), .enable(IRin), .BusMuxOut(BusMuxOut), .BusMuxIn(IR_data));

    mdr_unit mdr(
        .clear(clear),
        .clock(clock),
        .MDRin(MDRin),
        .Read(Read),
        .BusMuxOut(BusMuxOut),
        .Mdatain(Mdatain),
        .BusMuxInMDR(MDR_data)
    );

    ram memory_unit(
        .clk(clock),
        .read(Read),
        .write(Write),
        .address(MAR_data[8:0]),
        .data_in(MDR_data),
        .data_out(Mdatain)
    );

    ALU alu_inst(.A(Y_data), .B(BusMuxOut), .ALU_op(ALU_op), .C(ALU_out));

    Bus bus_inst(
        .BusMuxInR0(BusMuxInR0_eff), .BusMuxInR1(R_data[1]), .BusMuxInR2(R_data[2]), .BusMuxInR3(R_data[3]),
        .BusMuxInR4(R_data[4]), .BusMuxInR5(R_data[5]), .BusMuxInR6(R_data[6]), .BusMuxInR7(R_data[7]),
        .BusMuxInR8(R_data[8]), .BusMuxInR9(R_data[9]), .BusMuxInR10(R_data[10]), .BusMuxInR11(R_data[11]),
        .BusMuxInR12(R_data[12]), .BusMuxInR13(R_data[13]), .BusMuxInR14(R_data[14]), .BusMuxInR15(R_data[15]),
        .BusMuxInHI(HI_data), .BusMuxInLO(LO_data),
        .BusMuxInZhigh(Z_data[63:32]), .BusMuxInZlow(Z_data[31:0]),
        .BusMuxInPC(PC_data), .BusMuxInMDR(MDR_data), .BusMuxInInPort(InPort_data),
        .C_sign_extended(C_sign_extended),
        .R0out(R_out_dec[0]),  .R1out(R_out_dec[1]),  .R2out(R_out_dec[2]),  .R3out(R_out_dec[3]),
        .R4out(R_out_dec[4]),  .R5out(R_out_dec[5]),  .R6out(R_out_dec[6]),  .R7out(R_out_dec[7]),
        .R8out(R_out_dec[8]),  .R9out(R_out_dec[9]),  .R10out(R_out_dec[10]), .R11out(R_out_dec[11]),
        .R12out(R_out_dec[12]), .R13out(R_out_dec[13]), .R14out(R_out_dec[14]), .R15out(R_out_dec[15]),
        .HIout(HIout), .LOout(LOout), .Zhighout(Zhighout), .Zlowout(Zlowout),
        .PCout(PCout), .MDRout(MDRout), .InPortout(InPortout), .Cout(Cout),
        .BusMuxOut(BusMuxOut)
    );

    con_ff con_ff_inst (
        .clock(clock),
        .clear(clear),
        .CONin(CONin),
        .cond(IR_data[20:19]),
        .bus_data(BusMuxOut),
        .CON(CON_out)
    );

    register OutPort_reg (
        .clear(clear),
        .clock(clock),
        .enable(OutPortin),
        .BusMuxOut(BusMuxOut),
        .BusMuxIn(OutPort_data)
    );

    assign BusMuxOut_out = BusMuxOut;
    assign output_port = OutPort_data;
endmodule
