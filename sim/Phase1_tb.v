`timescale 1ns/10ps

module Phase1_tb;
    reg clock, clear;
    reg R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in;
    reg R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in;
    reg R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out;
    reg R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out;
    reg PCin, PCout, IncPC, IRin, Yin, Zin, HIin, LOin, MARin, MDRin, MDRout, Read;
    reg Zhighout, Zlowout, HIout, LOout, InPortout, Cout;
    reg [4:0] ALU_op;
    reg [31:0] Mdatain;
    wire [31:0] BusMuxOut_out;
    wire [31:0] BusMuxOut;
    wire [31:0] R0, R1, R2, R3, R4, R5, R6, R7;
    wire [31:0] R8, R9, R10, R11, R12, R13, R14, R15;
    wire [31:0] HI, LO, IR;
    wire [63:0] Z;

    integer errors;

    localparam ALU_ADD  = 5'd0;
    localparam ALU_SUB  = 5'd1;
    localparam ALU_MUL  = 5'd2;
    localparam ALU_DIV  = 5'd3;
    localparam ALU_SHR  = 5'd4;
    localparam ALU_SHRA = 5'd5;
    localparam ALU_SHL  = 5'd6;
    localparam ALU_ROR  = 5'd7;
    localparam ALU_ROL  = 5'd8;
    localparam ALU_AND  = 5'd9;
    localparam ALU_OR   = 5'd10;
    localparam ALU_NEG  = 5'd11;
    localparam ALU_NOT  = 5'd12;

    // Update these opcode values to match your CPU specification.
    localparam [4:0] OPC_ADD  = 5'd0;
    localparam [4:0] OPC_SUB  = 5'd1;
    localparam [4:0] OPC_AND  = 5'd2;  // matches example 0x112B0000 in Phase 1 doc
    localparam [4:0] OPC_OR   = 5'd3;
    localparam [4:0] OPC_ROR  = 5'd4;
    localparam [4:0] OPC_ROL  = 5'd5;
    localparam [4:0] OPC_SHR  = 5'd6;
    localparam [4:0] OPC_SHRA = 5'd7;
    localparam [4:0] OPC_SHL  = 5'd8;
    localparam [4:0] OPC_DIV  = 5'd12;
    localparam [4:0] OPC_MUL  = 5'd13;
    localparam [4:0] OPC_NEG  = 5'd14;
    localparam [4:0] OPC_NOT  = 5'd15;

    function automatic [31:0] instr_rrr;
        input [4:0] opcode;
        input [3:0] ra;
        input [3:0] rb;
        input [3:0] rc;
        begin
            instr_rrr = {opcode, ra, rb, rc, 15'b0};
        end
    endfunction

    function automatic [31:0] instr_rr;
        input [4:0] opcode;
        input [3:0] ra;
        input [3:0] rb;
        begin
            instr_rr = {opcode, ra, rb, 19'b0};
        end
    endfunction

    localparam [31:0] INSTR_AND_R2_R5_R6  = instr_rrr(OPC_AND, 4'd2, 4'd5, 4'd6);
    localparam [31:0] INSTR_OR_R2_R5_R6   = instr_rrr(OPC_OR,  4'd2, 4'd5, 4'd6);
    localparam [31:0] INSTR_ADD_R2_R5_R6  = instr_rrr(OPC_ADD, 4'd2, 4'd5, 4'd6);
    localparam [31:0] INSTR_SUB_R2_R5_R6  = instr_rrr(OPC_SUB, 4'd2, 4'd5, 4'd6);
    localparam [31:0] INSTR_MUL_R3_R1     = instr_rr(OPC_MUL,  4'd3, 4'd1);
    localparam [31:0] INSTR_DIV_R3_R1     = instr_rr(OPC_DIV,  4'd3, 4'd1);
    localparam [31:0] INSTR_SHR_R7_R0_R4  = instr_rrr(OPC_SHR, 4'd7, 4'd0, 4'd4);
    localparam [31:0] INSTR_SHRA_R7_R0_R4 = instr_rrr(OPC_SHRA,4'd7, 4'd0, 4'd4);
    localparam [31:0] INSTR_SHL_R7_R0_R4  = instr_rrr(OPC_SHL, 4'd7, 4'd0, 4'd4);
    localparam [31:0] INSTR_ROR_R7_R0_R4  = instr_rrr(OPC_ROR, 4'd7, 4'd0, 4'd4);
    localparam [31:0] INSTR_ROL_R7_R0_R4  = instr_rrr(OPC_ROL, 4'd7, 4'd0, 4'd4);
    localparam [31:0] INSTR_NEG_R4_R7     = instr_rr(OPC_NEG,  4'd4, 4'd7);
    localparam [31:0] INSTR_NOT_R4_R7     = instr_rr(OPC_NOT,  4'd4, 4'd7);

    DataPath DUT(
        .clock(clock), .clear(clear),
        .R0in(R0in), .R1in(R1in), .R2in(R2in), .R3in(R3in), .R4in(R4in), .R5in(R5in), .R6in(R6in), .R7in(R7in),
        .R8in(R8in), .R9in(R9in), .R10in(R10in), .R11in(R11in), .R12in(R12in), .R13in(R13in), .R14in(R14in), .R15in(R15in),
        .R0out(R0out), .R1out(R1out), .R2out(R2out), .R3out(R3out), .R4out(R4out), .R5out(R5out), .R6out(R6out), .R7out(R7out),
        .R8out(R8out), .R9out(R9out), .R10out(R10out), .R11out(R11out), .R12out(R12out), .R13out(R13out), .R14out(R14out), .R15out(R15out),
        .PCin(PCin), .PCout(PCout), .IncPC(IncPC), .IRin(IRin), .Yin(Yin), .Zin(Zin), .HIin(HIin), .LOin(LOin), .MARin(MARin), .MDRin(MDRin), .MDRout(MDRout), .Read(Read),
        .Zhighout(Zhighout), .Zlowout(Zlowout), .HIout(HIout), .LOout(LOout), .InPortout(InPortout), .Cout(Cout),
        .ALU_op(ALU_op),
        .Mdatain(Mdatain),
        .BusMuxOut_out(BusMuxOut_out)
    );

    assign BusMuxOut = BusMuxOut_out;
    assign R0  = DUT.R_data[0];
    assign R1  = DUT.R_data[1];
    assign R2  = DUT.R_data[2];
    assign R3  = DUT.R_data[3];
    assign R4  = DUT.R_data[4];
    assign R5  = DUT.R_data[5];
    assign R6  = DUT.R_data[6];
    assign R7  = DUT.R_data[7];
    assign R8  = DUT.R_data[8];
    assign R9  = DUT.R_data[9];
    assign R10 = DUT.R_data[10];
    assign R11 = DUT.R_data[11];
    assign R12 = DUT.R_data[12];
    assign R13 = DUT.R_data[13];
    assign R14 = DUT.R_data[14];
    assign R15 = DUT.R_data[15];
    assign HI  = DUT.HI_data;
    assign LO  = DUT.LO_data;
    assign IR  = DUT.IR_data;
    assign Z   = DUT.Z_data;

    always #10 clock = ~clock;

    task clear_controls;
        begin
            R0in = 0; R1in = 0; R2in = 0; R3in = 0; R4in = 0; R5in = 0; R6in = 0; R7in = 0;
            R8in = 0; R9in = 0; R10in = 0; R11in = 0; R12in = 0; R13in = 0; R14in = 0; R15in = 0;
            R0out = 0; R1out = 0; R2out = 0; R3out = 0; R4out = 0; R5out = 0; R6out = 0; R7out = 0;
            R8out = 0; R9out = 0; R10out = 0; R11out = 0; R12out = 0; R13out = 0; R14out = 0; R15out = 0;
            PCin = 0; PCout = 0; IncPC = 0; IRin = 0; Yin = 0; Zin = 0; HIin = 0; LOin = 0; MARin = 0; MDRin = 0; MDRout = 0; Read = 0;
            Zhighout = 0; Zlowout = 0; HIout = 0; LOout = 0; InPortout = 0; Cout = 0;
            ALU_op = ALU_ADD;
        end
    endtask

    task load_reg;
        input [3:0] idx;
        input [31:0] value;
        begin
            @(negedge clock);
            clear_controls();
            Mdatain = value;
            Read = 1; MDRin = 1;
            @(posedge clock);
            #1;
            clear_controls();
            @(negedge clock);
            MDRout = 1;
            case (idx)
                4'd0: R0in = 1;
                4'd1: R1in = 1;
                4'd2: R2in = 1;
                4'd3: R3in = 1;
                4'd4: R4in = 1;
                4'd5: R5in = 1;
                4'd6: R6in = 1;
                4'd7: R7in = 1;
                4'd8: R8in = 1;
                4'd9: R9in = 1;
                4'd10: R10in = 1;
                4'd11: R11in = 1;
                4'd12: R12in = 1;
                4'd13: R13in = 1;
                4'd14: R14in = 1;
                4'd15: R15in = 1;
                default: ;
            endcase
            @(posedge clock);
            #1;
            clear_controls();
            Mdatain = 32'b0;
        end
    endtask

    task expect32;
        input [31:0] actual;
        input [31:0] expected;
        input [127:0] label;
        begin
            if (actual !== expected) begin
                $display("FAIL %s: expected %h got %h", label, expected, actual);
                errors = errors + 1;
            end else begin
                $display("PASS %s: %h", label, actual);
            end
        end
    endtask

    initial begin
        clock = 0;
        clear = 1;
        errors = 0;
        Mdatain = 32'b0;
        clear_controls();
        $dumpfile("dump.vcd");
        $dumpvars(0, Phase1_tb);

        repeat (2) @(posedge clock);
        clear = 0;

        // AND R2, R5, R6
        load_reg(4'd5, 32'h00000034);
        load_reg(4'd6, 32'h00000045);
        @(negedge clock); clear_controls();
        PCout = 1; MARin = 1; IncPC = 1; Zin = 1; ALU_op = ALU_ADD;
        @(posedge clock); #1; clear_controls();
        @(negedge clock);
        Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; Mdatain = INSTR_AND_R2_R5_R6;
        @(posedge clock); #1; clear_controls();
        @(negedge clock);
        MDRout = 1; IRin = 1;
        @(posedge clock); #1; clear_controls();
        @(negedge clock);
        R5out = 1; Yin = 1;
        @(posedge clock); #1; clear_controls();
        @(negedge clock);
        R6out = 1; ALU_op = ALU_AND; Zin = 1;
        @(posedge clock); #1; clear_controls();
        @(negedge clock);
        Zlowout = 1; R2in = 1;
        @(posedge clock); #1; clear_controls();
        expect32(R2, 32'h00000004, "AND");

        // // OR R2, R5, R6
        // @(negedge clock); clear_controls();
        // PCout = 1; MARin = 1; IncPC = 1; Zin = 1; ALU_op = ALU_ADD;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; Mdatain = INSTR_OR_R2_R5_R6;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // MDRout = 1; IRin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R5out = 1; Yin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R6out = 1; ALU_op = ALU_OR; Zin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; R2in = 1;
        // @(posedge clock); #1; clear_controls();
        // expect32(R2, 32'h00000075, "OR");

        // // ADD R2, R5, R6
        // load_reg(4'd5, 32'h00000010);
        // load_reg(4'd6, 32'h00000005);
        // @(negedge clock); clear_controls();
        // PCout = 1; MARin = 1; IncPC = 1; Zin = 1; ALU_op = ALU_ADD;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; Mdatain = INSTR_ADD_R2_R5_R6;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // MDRout = 1; IRin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R5out = 1; Yin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R6out = 1; ALU_op = ALU_ADD; Zin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; R2in = 1;
        // @(posedge clock); #1; clear_controls();
        // expect32(R2, 32'h00000015, "ADD");

        // // SUB R2, R5, R6
        // @(negedge clock); clear_controls();
        // PCout = 1; MARin = 1; IncPC = 1; Zin = 1; ALU_op = ALU_ADD;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; Mdatain = INSTR_SUB_R2_R5_R6;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // MDRout = 1; IRin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R5out = 1; Yin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R6out = 1; ALU_op = ALU_SUB; Zin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; R2in = 1;
        // @(posedge clock); #1; clear_controls();
        // expect32(R2, 32'h0000000B, "SUB");

        // // MUL R3, R1
        // load_reg(4'd3, 32'h00000007);
        // load_reg(4'd1, 32'h00000003);
        // @(negedge clock); clear_controls();
        // PCout = 1; MARin = 1; IncPC = 1; Zin = 1; ALU_op = ALU_ADD;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; Mdatain = INSTR_MUL_R3_R1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // MDRout = 1; IRin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R3out = 1; Yin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R1out = 1; ALU_op = ALU_MUL; Zin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; LOin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zhighout = 1; HIin = 1;
        // @(posedge clock); #1; clear_controls();
        // expect32(LO, 32'h00000015, "MUL LO");
        // expect32(HI, 32'h00000000, "MUL HI");

        // // DIV R3, R1
        // load_reg(4'd3, 32'h00000014);
        // load_reg(4'd1, 32'h00000003);
        // @(negedge clock); clear_controls();
        // PCout = 1; MARin = 1; IncPC = 1; Zin = 1; ALU_op = ALU_ADD;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; Mdatain = INSTR_DIV_R3_R1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // MDRout = 1; IRin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R3out = 1; Yin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R1out = 1; ALU_op = ALU_DIV; Zin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; LOin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zhighout = 1; HIin = 1;
        // @(posedge clock); #1; clear_controls();
        // expect32(LO, 32'h00000006, "DIV LO");
        // expect32(HI, 32'h00000002, "DIV HI");

        // // SHR R7, R0, R4
        // load_reg(4'd0, 32'h00000010);
        // load_reg(4'd4, 32'h00000002);
        // @(negedge clock); clear_controls();
        // PCout = 1; MARin = 1; IncPC = 1; Zin = 1; ALU_op = ALU_ADD;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; Mdatain = INSTR_SHR_R7_R0_R4;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // MDRout = 1; IRin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R0out = 1; Yin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R4out = 1; ALU_op = ALU_SHR; Zin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; R7in = 1;
        // @(posedge clock); #1; clear_controls();
        // expect32(R7, 32'h00000004, "SHR");

        // // SHRA R7, R0, R4
        // load_reg(4'd0, 32'h80000000);
        // load_reg(4'd4, 32'h00000001);
        // @(negedge clock); clear_controls();
        // PCout = 1; MARin = 1; IncPC = 1; Zin = 1; ALU_op = ALU_ADD;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; Mdatain = INSTR_SHRA_R7_R0_R4;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // MDRout = 1; IRin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R0out = 1; Yin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R4out = 1; ALU_op = ALU_SHRA; Zin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; R7in = 1;
        // @(posedge clock); #1; clear_controls();
        // expect32(R7, 32'hC0000000, "SHRA");

        // // SHL R7, R0, R4
        // load_reg(4'd0, 32'h00000001);
        // load_reg(4'd4, 32'h00000003);
        // @(negedge clock); clear_controls();
        // PCout = 1; MARin = 1; IncPC = 1; Zin = 1; ALU_op = ALU_ADD;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; Mdatain = INSTR_SHL_R7_R0_R4;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // MDRout = 1; IRin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R0out = 1; Yin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R4out = 1; ALU_op = ALU_SHL; Zin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; R7in = 1;
        // @(posedge clock); #1; clear_controls();
        // expect32(R7, 32'h00000008, "SHL");

        // // ROR R7, R0, R4
        // load_reg(4'd0, 32'h80000001);
        // load_reg(4'd4, 32'h00000001);
        // @(negedge clock); clear_controls();
        // PCout = 1; MARin = 1; IncPC = 1; Zin = 1; ALU_op = ALU_ADD;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; Mdatain = INSTR_ROR_R7_R0_R4;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // MDRout = 1; IRin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R0out = 1; Yin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R4out = 1; ALU_op = ALU_ROR; Zin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; R7in = 1;
        // @(posedge clock); #1; clear_controls();
        // expect32(R7, 32'hC0000000, "ROR");

        // // ROL R7, R0, R4
        // load_reg(4'd0, 32'h80000001);
        // load_reg(4'd4, 32'h00000001);
        // @(negedge clock); clear_controls();
        // PCout = 1; MARin = 1; IncPC = 1; Zin = 1; ALU_op = ALU_ADD;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; Mdatain = INSTR_ROL_R7_R0_R4;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // MDRout = 1; IRin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R0out = 1; Yin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R4out = 1; ALU_op = ALU_ROL; Zin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; R7in = 1;
        // @(posedge clock); #1; clear_controls();
        // expect32(R7, 32'h00000003, "ROL");

        // // NEG R4, R7
        // load_reg(4'd7, 32'h00000009);
        // @(negedge clock); clear_controls();
        // PCout = 1; MARin = 1; IncPC = 1; Zin = 1; ALU_op = ALU_ADD;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; Mdatain = INSTR_NEG_R4_R7;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // MDRout = 1; IRin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R7out = 1; ALU_op = ALU_NEG; Zin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; R4in = 1;
        // @(posedge clock); #1; clear_controls();
        // expect32(R4, 32'hFFFFFFF7, "NEG");

        // // NOT R4, R7
        // load_reg(4'd7, 32'h0000000F);
        // @(negedge clock); clear_controls();
        // PCout = 1; MARin = 1; IncPC = 1; Zin = 1; ALU_op = ALU_ADD;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; Mdatain = INSTR_NOT_R4_R7;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // MDRout = 1; IRin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // R7out = 1; ALU_op = ALU_NOT; Zin = 1;
        // @(posedge clock); #1; clear_controls();
        // @(negedge clock);
        // Zlowout = 1; R4in = 1;
        // @(posedge clock); #1; clear_controls();
        // expect32(R4, 32'hFFFFFFF0, "NOT");

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTS FAILED: %0d errors", errors);

        $finish;
    end
endmodule