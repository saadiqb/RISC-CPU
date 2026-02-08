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
    wire [31:0] Y_data, HI_data, LO_data, PC_data, MDR_data, MAR_data, IR_data, InPort_data;
    wire [63:0] Z_data;

    // Instantiate R0-R15 [cite: 84]
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : reg_gen
            register r(clear, clock, (i == 0 ? R0in : (i == 1 ? R1in : ...)), BusMuxOut, R_data[i]);
        end
    endgenerate

    // Dedicated Registers [cite: 132, 133, 136]
    register #(.DATA_WIDTH(64)) Z(clear, clock, Zin, Z_data, Z_data);
    register Y(clear, clock, Yin, BusMuxOut, Y_data);
    register PC(clear, clock, PCin, BusMuxOut, PC_data);
    register HI(clear, clock, HIin, BusMuxOut, HI_data);
    register LO(clear, clock, LOin, BusMuxOut, LO_data);
    mdr_unit mdr(clear, clock, MDRin, Read, BusMuxOut, Mdatain, MDR_data);

    // ALU Integration [cite: 117, 120]
    ALU alu_inst(Y_data, BusMuxOut, ALU_op, Z_data);

    // Bus Integration [cite: 170]
    Bus bus_inst(
        .BusMuxInR0(R_data[0]), .BusMuxInR1(R_data[1]), // ... connect others
        .BusMuxInHI(HI_data), .BusMuxInLO(LO_data), 
        .BusMuxInZhigh(Z_data[63:32]), .BusMuxInZlow(Z_data[31:0]),
        .BusMuxInPC(PC_data), .BusMuxInMDR(MDR_data),
        .BusSelect(BusSelect) // Derived from 'out' signals in Bus module
    );
endmodule