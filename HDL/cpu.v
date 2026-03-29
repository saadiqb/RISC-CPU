`timescale 1ns/10ps

module cpu(
    input wire clock,
    input wire reset,
    input wire stop,
    input wire [31:0] in_port_data,
    output wire [31:0] out_port_data,
    output wire [31:0] BusMuxOut_out
);

    // Internal wires for Control Unit <-> DataPath communication
    wire clear;
    wire Gra, Grb, Grc;
    wire Rin_ctrl, Rout_ctrl, BAout;
    wire PCin, PCout, IncPC, IRin, Yin, Zin, HIin, LOin, MARin, MDRin, MDRout;
    wire Read, Write;
    wire Zhighout, Zlowout, HIout, LOout;
    wire InPortout, Cout;
    wire [4:0] ALU_op;
    wire CONin, OutPortin, InPortin;
    wire CON_out;
    
    wire [31:0] IR_data_wire;

    // Instantiate DataPath
    DataPath datapath_inst (
        .clock(clock), 
        .clear(clear), // Driven by control unit reset state
        .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .Rin_ctrl(Rin_ctrl), .Rout_ctrl(Rout_ctrl), .BAout(BAout),
        .PCin(PCin), .PCout(PCout), .IncPC(IncPC), .IRin(IRin), 
        .Yin(Yin), .Zin(Zin), .HIin(HIin), .LOin(LOin), 
        .MARin(MARin), .MDRin(MDRin), .MDRout(MDRout), 
        .Read(Read), .Write(Write), 
        .Zhighout(Zhighout), .Zlowout(Zlowout), .HIout(HIout), .LOout(LOout), 
        .InPortout(InPortout), .Cout(Cout),
        .ALU_op(ALU_op),
        .CONin(CONin), .OutPortin(OutPortin), .InPortin(InPortin),
        .in_port_data(in_port_data), 
        .out_port_data(out_port_data), 
        .CON_out(CON_out),
        .BusMuxOut_out(BusMuxOut_out),
        .IR_data_out(IR_data_wire) // Ensure this is added to DataPath.v
    );

    // Instantiate Control Unit
    control_unit cu_inst (
        .clock(clock), 
        .reset(reset), 
        .stop(stop),
        .IR(IR_data_wire), 
        .CON_out(CON_out),
        .clear(clear),
        .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .Rin_ctrl(Rin_ctrl), .Rout_ctrl(Rout_ctrl), .BAout(BAout),
        .PCin(PCin), .PCout(PCout), .IncPC(IncPC), .IRin(IRin), 
        .Yin(Yin), .Zin(Zin), .HIin(HIin), .LOin(LOin), 
        .MARin(MARin), .MDRin(MDRin), .MDRout(MDRout), 
        .Read(Read), .Write(Write), 
        .Zhighout(Zhighout), .Zlowout(Zlowout), .HIout(HIout), .LOout(LOout), 
        .InPortout(InPortout), .Cout(Cout),
        .CONin(CONin), .OutPortin(OutPortin), .InPortin(InPortin),
        .ALU_op(ALU_op)
    );

endmodule