`timescale 1ns/10ps

// Phase 2 Section 3 — Lab procedure: exact control sequences from the Phase 2 handout.
// No control unit; each step matches T0, T1, … as documented.

module Phase2_tb;
    reg clock, clear;
    reg Gra, Grb, Grc, Rin, Rout, BAout;
    reg PCin, PCout, IncPC, IRin, Yin, Zin, HIin, LOin, MARin, MDRin, MDRout, Read, Write;
    reg Zhighout, Zlowout, HIout, LOout, InPortout, Cout;
    reg CONin, OutPortin;
    reg [31:0] input_port;
    reg [4:0] ALU_op;
    wire [31:0] BusMuxOut_out;
    wire CON_out;
    wire [31:0] output_port;

    wire [31:0] R0, R1, R2, R3, R4, R5, R6, R7;
    wire [31:0] R8, R9, R10, R11, R12, R13, R14, R15;
    wire [31:0] HI, LO, IR;
    wire [63:0] Z;
    wire [31:0] PC_val, MAR_val, MDR_val;

    integer errors;
    integer scratch_mem_addr;

    // ALU (datapath internal encoding — matches ALU.v)
    localparam ALU_ADD  = 5'd0;
    localparam ALU_AND  = 5'd9;
    localparam ALU_OR   = 5'd10;

    // Mini SRC instruction opcodes (CPU specification)
    localparam [4:0] OP_LD   = 5'b10000;
    localparam [4:0] OP_LDI  = 5'b10001;
    localparam [4:0] OP_ST   = 5'b10010;
    localparam [4:0] OP_JAL  = 5'b10011;
    localparam [4:0] OP_JR   = 5'b10100;
    localparam [4:0] OP_BR   = 5'b10101;
    localparam [4:0] OP_IN   = 5'b10110;
    localparam [4:0] OP_OUT  = 5'b10111;
    localparam [4:0] OP_MFHI = 5'b11000;
    localparam [4:0] OP_MFLO = 5'b11001;
    localparam [4:0] OP_ADDI = 5'b01001;
    localparam [4:0] OP_ANDI = 5'b01010;
    localparam [4:0] OP_ORI  = 5'b01011;

    // I-format: {op, ra, rb, c[18:0]}
    function automatic [31:0] i_instr;
        input [4:0] op;
        input [3:0] ra, rb;
        input [18:0] c19;
        i_instr = {op, ra, rb, c19};
    endfunction

    // J-format: opcode + Ra + unused (32 bits total)
    function automatic [31:0] j_instr;
        input [4:0] op;
        input [3:0] ra;
        j_instr = {op, ra, 23'b0};
    endfunction

    // Branch: {OP_BR, ra, 2'b00, cond[1:0], c[18:0]} — cond in IR[20:19] per Phase 2 Figure 7
    function automatic [31:0] br_instr;
        input [3:0] ra;
        input [1:0] cond;
        input [18:0] c19;
        br_instr = {OP_BR, ra, 2'b00, cond, c19};
    endfunction

    // Force IR view for jal link step (Ra=12) without changing IR register contents
    function automatic [31:0] ir_ra12_dummy;
        ir_ra12_dummy = {5'b0, 4'd12, 23'b0};
    endfunction

    DataPath DUT (
        .clock(clock), .clear(clear),
        .Gra(Gra), .Grb(Grb), .Grc(Grc), .Rin(Rin), .Rout(Rout), .BAout(BAout),
        .PCin(PCin), .PCout(PCout), .IncPC(IncPC), .IRin(IRin), .Yin(Yin), .Zin(Zin),
        .HIin(HIin), .LOin(LOin), .MARin(MARin), .MDRin(MDRin), .MDRout(MDRout),
        .Read(Read), .Write(Write),
        .Zhighout(Zhighout), .Zlowout(Zlowout), .HIout(HIout), .LOout(LOout),
        .InPortout(InPortout), .Cout(Cout),
        .CONin(CONin),
        .input_port(input_port),
        .OutPortin(OutPortin),
        .ALU_op(ALU_op),
        .BusMuxOut_out(BusMuxOut_out),
        .CON_out(CON_out),
        .output_port(output_port)
    );

    assign R0 = DUT.R_data[0];  assign R1  = DUT.R_data[1];  assign R2  = DUT.R_data[2];
    assign R3 = DUT.R_data[3];  assign R4  = DUT.R_data[4];  assign R5  = DUT.R_data[5];
    assign R6 = DUT.R_data[6];  assign R7  = DUT.R_data[7];  assign R8  = DUT.R_data[8];
    assign R9 = DUT.R_data[9];  assign R10 = DUT.R_data[10]; assign R11 = DUT.R_data[11];
    assign R12 = DUT.R_data[12]; assign R13 = DUT.R_data[13]; assign R14 = DUT.R_data[14];
    assign R15 = DUT.R_data[15];
    assign HI = DUT.HI_data; assign LO = DUT.LO_data; assign IR = DUT.IR_data; assign Z = DUT.Z_data;
    assign PC_val = DUT.PC_data;
    assign MAR_val = DUT.MAR_data;
    assign MDR_val = DUT.MDR_data;

    always #10 clock = ~clock;

    task clear_controls;
        begin
            Gra = 0; Grb = 0; Grc = 0; Rin = 0; Rout = 0; BAout = 0;
            PCin = 0; PCout = 0; IncPC = 0; IRin = 0; Yin = 0; Zin = 0;
            HIin = 0; LOin = 0; MARin = 0; MDRin = 0; MDRout = 0; Read = 0; Write = 0;
            Zhighout = 0; Zlowout = 0; HIout = 0; LOout = 0; InPortout = 0; Cout = 0;
            CONin = 0; OutPortin = 0;
            ALU_op = ALU_ADD;
        end
    endtask

    task expect32;
        input [31:0] actual, expected;
        input [255:0] label;
        begin
            if (actual !== expected) begin
                $display("FAIL %s: exp %h got %h", label, expected, actual);
                errors = errors + 1;
            end else
                $display("PASS %s", label);
        end
    endtask

    task expect32_mem;
        input [8:0] addr;
        input [31:0] expected;
        input [255:0] label;
        begin
            if (DUT.memory_unit.mem_array[addr] !== expected) begin
                $display("FAIL %s [@%03x]: exp %h got %h", label, addr, expected,
                    DUT.memory_unit.mem_array[addr]);
                errors = errors + 1;
            end else
                $display("PASS %s [@%03x]=%h", label, addr, expected);
        end
    endtask

    // --- Common instruction fetch: T0–T2 (handout) ---
    // Pre: instruction word at mem[pc_word_addr]. Forces PC bus view for T0 if needed.
    task run_fetch_T0_T2;
        input [31:0] pc_word_addr;
        begin
            // T0: PCout, MARin, IncPC, Zin
            @(negedge clock);
            clear_controls();
            force DUT.PC_data = pc_word_addr;
            PCout = 1;
            MARin = 1;
            IncPC = 1;
            Zin = 1;
            ALU_op = ALU_ADD;
            @(posedge clock);
            #1;
            release DUT.PC_data;
            clear_controls();

            // T1: Zlowout, PCin, Read, MDRin
            @(negedge clock);
            clear_controls();
            Zlowout = 1;
            PCin = 1;
            Read = 1;
            MDRin = 1;
            @(posedge clock);
            #1;
            clear_controls();

            // T2: MDRout, IRin
            @(negedge clock);
            clear_controls();
            MDRout = 1;
            IRin = 1;
            @(posedge clock);
            #1;
            clear_controls();
        end
    endtask

    // Load GPR from RAM scratch (for preloading R2, R6, etc.)
    task load_gpr_from_mem;
        input [3:0] ra_idx;
        input [31:0] value;
        reg [8:0] a;
        begin
            a = scratch_mem_addr[8:0];
            scratch_mem_addr = scratch_mem_addr + 1;
            DUT.memory_unit.mem_array[a] = value;
            @(negedge clock);
            clear_controls();
            force DUT.MAR_data = {23'd0, a};
            Read = 1;
            MDRin = 1;
            @(posedge clock);
            #1;
            release DUT.MAR_data;
            clear_controls();
            @(negedge clock);
            clear_controls();
            force DUT.IR_data = {5'b0, ra_idx, 23'b0};
            Gra = 1;
            Rin = 1;
            MDRout = 1;
            @(posedge clock);
            #1;
            clear_controls();
            release DUT.IR_data;
        end
    endtask

    task load_hi_from_mem;
        input [31:0] value;
        reg [8:0] a;
        begin
            a = scratch_mem_addr[8:0];
            scratch_mem_addr = scratch_mem_addr + 1;
            DUT.memory_unit.mem_array[a] = value;
            @(negedge clock);
            clear_controls();
            force DUT.MAR_data = {23'd0, a};
            Read = 1;
            MDRin = 1;
            @(posedge clock);
            #1;
            release DUT.MAR_data;
            clear_controls();
            @(negedge clock);
            MDRout = 1;
            HIin = 1;
            @(posedge clock);
            #1;
            clear_controls();
        end
    endtask

    task load_lo_from_mem;
        input [31:0] value;
        reg [8:0] a;
        begin
            a = scratch_mem_addr[8:0];
            scratch_mem_addr = scratch_mem_addr + 1;
            DUT.memory_unit.mem_array[a] = value;
            @(negedge clock);
            clear_controls();
            force DUT.MAR_data = {23'd0, a};
            Read = 1;
            MDRin = 1;
            @(posedge clock);
            #1;
            release DUT.MAR_data;
            clear_controls();
            @(negedge clock);
            MDRout = 1;
            LOin = 1;
            @(posedge clock);
            #1;
            clear_controls();
        end
    endtask

    // --- §3.1 ld: T3–T7 ---
    task run_ld_T3_T7;
        begin
            @(negedge clock);
            clear_controls();
            Grb = 1;
            BAout = 1;
            Yin = 1;
            @(posedge clock);
            #1;
            clear_controls();

            @(negedge clock);
            clear_controls();
            Cout = 1;
            ALU_op = ALU_ADD;
            Zin = 1;
            @(posedge clock);
            #1;
            clear_controls();

            @(negedge clock);
            clear_controls();
            Zlowout = 1;
            MARin = 1;
            @(posedge clock);
            #1;
            clear_controls();

            @(negedge clock);
            clear_controls();
            Read = 1;
            MDRin = 1;
            @(posedge clock);
            #1;
            clear_controls();

            @(negedge clock);
            clear_controls();
            MDRout = 1;
            Gra = 1;
            Rin = 1;
            @(posedge clock);
            #1;
            clear_controls();
        end
    endtask

    // --- §3.1 ldi: T3–T5 ---
    task run_ldi_T3_T5;
        begin
            @(negedge clock);
            clear_controls();
            Grb = 1;
            BAout = 1;
            Yin = 1;
            @(posedge clock);
            #1;
            clear_controls();

            @(negedge clock);
            clear_controls();
            Cout = 1;
            ALU_op = ALU_ADD;
            Zin = 1;
            @(posedge clock);
            #1;
            clear_controls();

            @(negedge clock);
            clear_controls();
            Zlowout = 1;
            Gra = 1;
            Rin = 1;
            @(posedge clock);
            #1;
            clear_controls();
        end
    endtask

    // --- §3.2 st: effective address T3–T5 (same as ld), then T6–T7 store ---
    task run_st_ea_T3_T5;
        begin
            @(negedge clock);
            clear_controls();
            Grb = 1;
            BAout = 1;
            Yin = 1;
            @(posedge clock);
            #1;
            clear_controls();

            @(negedge clock);
            clear_controls();
            Cout = 1;
            ALU_op = ALU_ADD;
            Zin = 1;
            @(posedge clock);
            #1;
            clear_controls();

            @(negedge clock);
            clear_controls();
            Zlowout = 1;
            MARin = 1;
            @(posedge clock);
            #1;
            clear_controls();
        end
    endtask

    task run_st_T6_T7;
        begin
            // T6: put R[Ra] (Gra field) into MDR from bus
            @(negedge clock);
            clear_controls();
            Gra = 1;
            Rout = 1;
            MDRin = 1;
            Read = 0;
            @(posedge clock);
            #1;
            clear_controls();

            // T7: memory write
            @(negedge clock);
            clear_controls();
            Write = 1;
            Read = 0;
            @(posedge clock);
            #1;
            clear_controls();
        end
    endtask

    // --- §3.3 immediate ALU: T3–T5 ---
    task run_immed_T3_T5;
        input [4:0] alu_sel;
        begin
            @(negedge clock);
            clear_controls();
            Grb = 1;
            Rout = 1;
            Yin = 1;
            @(posedge clock);
            #1;
            clear_controls();

            @(negedge clock);
            clear_controls();
            Cout = 1;
            ALU_op = alu_sel;
            Zin = 1;
            @(posedge clock);
            #1;
            clear_controls();

            @(negedge clock);
            clear_controls();
            Zlowout = 1;
            Gra = 1;
            Rin = 1;
            @(posedge clock);
            #1;
            clear_controls();
        end
    endtask

    // --- §3.4 branch: T3–T6 ---
    task run_branch_T3_T6;
        input take_branch;
        begin
            @(negedge clock);
            clear_controls();
            Gra = 1;
            Rout = 1;
            CONin = 1;
            @(posedge clock);
            #1;
            clear_controls();

            @(negedge clock);
            clear_controls();
            PCout = 1;
            Yin = 1;
            @(posedge clock);
            #1;
            clear_controls();

            @(negedge clock);
            clear_controls();
            Cout = 1;
            ALU_op = ALU_ADD;
            Zin = 1;
            @(posedge clock);
            #1;
            clear_controls();

            @(negedge clock);
            clear_controls();
            Zlowout = 1;
            if (take_branch)
                PCin = 1;
            @(posedge clock);
            #1;
            clear_controls();
        end
    endtask

    // --- §3.5 jr: T3 ---
    task run_jr_T3;
        begin
            @(negedge clock);
            clear_controls();
            Gra = 1;
            Rout = 1;
            PCin = 1;
            @(posedge clock);
            #1;
            clear_controls();
        end
    endtask

    // --- §3.5 jal: link (PC→R12) then jump (R[Ra]→PC) ---
    task run_jal_T3_T4;
        begin
            // T3 (link): R12 <- PC — decode Ra=12 via forced IR bus view
            @(negedge clock);
            clear_controls();
            force DUT.IR_data = ir_ra12_dummy();
            PCout = 1;
            Gra = 1;
            Rin = 1;
            @(posedge clock);
            #1;
            clear_controls();
            release DUT.IR_data;

            // T4 (jump): PC <- R[Ra] from true IR
            @(negedge clock);
            clear_controls();
            Gra = 1;
            Rout = 1;
            PCin = 1;
            @(posedge clock);
            #1;
            clear_controls();
        end
    endtask

    // --- §3.6 mfhi / mflo: T3 ---
    task run_mfhi_T3;
        begin
            @(negedge clock);
            clear_controls();
            HIout = 1;
            Gra = 1;
            Rin = 1;
            @(posedge clock);
            #1;
            clear_controls();
        end
    endtask

    task run_mflo_T3;
        begin
            @(negedge clock);
            clear_controls();
            LOout = 1;
            Gra = 1;
            Rin = 1;
            @(posedge clock);
            #1;
            clear_controls();
        end
    endtask

    // --- §3.7 out / in: T3 ---
    task run_out_T3;
        begin
            @(negedge clock);
            clear_controls();
            Gra = 1;
            Rout = 1;
            OutPortin = 1;
            @(posedge clock);
            #1;
            clear_controls();
        end
    endtask

    task run_in_T3;
        begin
            @(negedge clock);
            clear_controls();
            InPortout = 1;
            Gra = 1;
            Rin = 1;
            @(posedge clock);
            #1;
            clear_controls();
        end
    endtask

    initial begin
        clock = 0;
        errors = 0;
        scratch_mem_addr = 1;
        input_port = 32'b0;
        clear_controls();
        // VCD for GTKWave / ModelSim waveform viewers (run vvp from repo root)
        $dumpfile("sim/phase2.vcd");
        $dumpvars(0, Phase2_tb);

        repeat (2) @(posedge clock);
        clear = 1;
        repeat (2) @(posedge clock);
        clear = 0;
        clear_controls();

        $display("\n=== 3.1 Load: ld / ldi ===");

        // Case 1: ld R7, 0x65 — mem[0x65]=0x84, Rb=R0
        DUT.memory_unit.mem_array[9'h65] = 32'h00000084;
        DUT.memory_unit.mem_array[0] = i_instr(OP_LD, 4'd7, 4'd0, 19'h00065);
        run_fetch_T0_T2(32'd0);
        run_ld_T3_T7();
        expect32(R7, 32'h00000084, "3.1 Case1 ld R7,0x65");

        // Case 2: ld R0, 0x72(R2) — R2=0x57, mem[0xC9]=0x2B
        load_gpr_from_mem(4'd2, 32'h00000057);
        DUT.memory_unit.mem_array[9'hC9] = 32'h0000002B;
        DUT.memory_unit.mem_array[1] = i_instr(OP_LD, 4'd0, 4'd2, 19'h00072);
        run_fetch_T0_T2(32'd1);
        run_ld_T3_T7();
        expect32(R0, 32'h0000002B, "3.1 Case2 ld R0,0x72(R2)");

        // Case 3: ldi R7, 0x65
        DUT.memory_unit.mem_array[2] = i_instr(OP_LDI, 4'd7, 4'd0, 19'h00065);
        run_fetch_T0_T2(32'd2);
        run_ldi_T3_T5();
        expect32(R7, 32'h00000065, "3.1 Case3 ldi R7,0x65");

        // Case 4: ldi R0, 0x72(R2) — R2=0x57 → R0 = 0x57+0x72 = 0xC9
        load_gpr_from_mem(4'd2, 32'h00000057);
        DUT.memory_unit.mem_array[3] = i_instr(OP_LDI, 4'd0, 4'd2, 19'h00072);
        run_fetch_T0_T2(32'd3);
        run_ldi_T3_T5();
        expect32(R0, 32'h000000C9, "3.1 Case4 ldi R0,0x72(R2)");

        // $display("\n=== 3.2 Store: st ===");

        // // Case 1: st 0x1F, R6 — direct Rb=0, R6=0x63, was 0xD4
        // load_gpr_from_mem(4'd6, 32'h00000063);
        // DUT.memory_unit.mem_array[9'h01F] = 32'h000000D4;
        // DUT.memory_unit.mem_array[4] = i_instr(OP_ST, 4'd6, 4'd0, 19'h0001F);
        // run_fetch_T0_T2(32'd4);
        // run_st_ea_T3_T5();
        // run_st_T6_T7();
        // expect32_mem(9'h01F, 32'h00000063, "3.2 Case1 st 0x1F,R6");

        // // Case 2: st 0x1F(R6), R6 — R6=0x63, EA=0x82, was 0xA7
        // load_gpr_from_mem(4'd6, 32'h00000063);
        // DUT.memory_unit.mem_array[9'h082] = 32'h000000A7;
        // DUT.memory_unit.mem_array[5] = i_instr(OP_ST, 4'd6, 4'd6, 19'h0001F);
        // run_fetch_T0_T2(32'd5);
        // run_st_ea_T3_T5();
        // run_st_T6_T7();
        // expect32_mem(9'h082, 32'h00000063, "3.2 Case2 st 0x1F(R6),R6");

        // $display("\n=== 3.3 ALU immediate: addi, andi, ori ===");

        // // addi R7, R4, -9
        // load_gpr_from_mem(4'd4, 32'h00000010);
        // DUT.memory_unit.mem_array[6] = i_instr(OP_ADDI, 4'd7, 4'd4, 19'h7FFF7);
        // run_fetch_T0_T2(32'd6);
        // run_immed_T3_T5(ALU_ADD);
        // expect32(R7, 32'h00000007, "3.3 addi R7,R4,-9");

        // // andi R7, R4, 0x71
        // load_gpr_from_mem(4'd4, 32'h000000FF);
        // DUT.memory_unit.mem_array[7] = i_instr(OP_ANDI, 4'd7, 4'd4, 19'h00071);
        // run_fetch_T0_T2(32'd7);
        // run_immed_T3_T5(ALU_AND);
        // expect32(R7, 32'h00000071, "3.3 andi R7,R4,0x71");

        // // ori R7, R4, 0x71
        // load_gpr_from_mem(4'd4, 32'h0000000F);
        // DUT.memory_unit.mem_array[8] = i_instr(OP_ORI, 4'd7, 4'd4, 19'h00071);
        // run_fetch_T0_T2(32'd8);
        // run_immed_T3_T5(ALU_OR);
        // expect32(R7, 32'h0000007F, "3.3 ori R7,R4,0x71");

        // $display("\n=== 3.4 Branch: brzr, brnz, brpl, brmi ===");
        // // Offset C=48; after fetch PC = instr_addr+1. New PC if taken = (instr_addr+1)+48

        // // brzr — taken (R3=0)
        // load_gpr_from_mem(4'd3, 32'h0);
        // DUT.memory_unit.mem_array[9'h10] = br_instr(4'd3, 2'b00, 19'd48);
        // run_fetch_T0_T2(32'h10);
        // run_branch_T3_T6(1'b1);
        // expect32(PC_val, 32'h10 + 32'd1 + 32'd48, "3.4 brzr taken");

        // // brzr — not taken (R3=5)
        // load_gpr_from_mem(4'd3, 32'h5);
        // DUT.memory_unit.mem_array[9'h20] = br_instr(4'd3, 2'b00, 19'd48);
        // run_fetch_T0_T2(32'h20);
        // run_branch_T3_T6(1'b0);
        // expect32(PC_val, 32'h21, "3.4 brzr not taken");

        // // brnz — taken (R3=5)
        // load_gpr_from_mem(4'd3, 32'h5);
        // DUT.memory_unit.mem_array[9'h30] = br_instr(4'd3, 2'b01, 19'd48);
        // run_fetch_T0_T2(32'h30);
        // run_branch_T3_T6(1'b1);
        // expect32(PC_val, 32'h30 + 32'd1 + 32'd48, "3.4 brnz taken");

        // // brnz — not taken (R3=0)
        // load_gpr_from_mem(4'd3, 32'h0);
        // DUT.memory_unit.mem_array[9'h40] = br_instr(4'd3, 2'b01, 19'd48);
        // run_fetch_T0_T2(32'h40);
        // run_branch_T3_T6(1'b0);
        // expect32(PC_val, 32'h41, "3.4 brnz not taken");

        // // brpl — taken (R3=5, MSB=0)
        // load_gpr_from_mem(4'd3, 32'h5);
        // DUT.memory_unit.mem_array[9'h50] = br_instr(4'd3, 2'b10, 19'd48);
        // run_fetch_T0_T2(32'h50);
        // run_branch_T3_T6(1'b1);
        // expect32(PC_val, 32'h50 + 32'd1 + 32'd48, "3.4 brpl taken");

        // // brpl — not taken (R3=-1)
        // load_gpr_from_mem(4'd3, 32'hFFFFFFFF);
        // DUT.memory_unit.mem_array[9'h60] = br_instr(4'd3, 2'b10, 19'd48);
        // run_fetch_T0_T2(32'h60);
        // run_branch_T3_T6(1'b0);
        // expect32(PC_val, 32'h61, "3.4 brpl not taken");

        // // brmi — taken (R3=-1)
        // load_gpr_from_mem(4'd3, 32'hFFFFFFFF);
        // DUT.memory_unit.mem_array[9'h70] = br_instr(4'd3, 2'b11, 19'd48);
        // run_fetch_T0_T2(32'h70);
        // run_branch_T3_T6(1'b1);
        // expect32(PC_val, 32'h70 + 32'd1 + 32'd48, "3.4 brmi taken");

        // // brmi — not taken (R3=5)
        // load_gpr_from_mem(4'd3, 32'h5);
        // DUT.memory_unit.mem_array[9'h80] = br_instr(4'd3, 2'b11, 19'd48);
        // run_fetch_T0_T2(32'h80);
        // run_branch_T3_T6(1'b0);
        // expect32(PC_val, 32'h81, "3.4 brmi not taken");

        // $display("\n=== 3.5 Jump: jr, jal ===");

        // // jr R12 — PC=0x10 before fetch, R12=0xFF; instr at mem[0x10]
        // load_gpr_from_mem(4'd12, 32'h000000FF);
        // DUT.memory_unit.mem_array[9'h10] = j_instr(OP_JR, 4'd12);
        // run_fetch_T0_T2(32'h10);
        // run_jr_T3();
        // expect32(PC_val, 32'h000000FF, "3.5 jr R12");

        // // jal R4 — PC=0x10 before fetch, R4=0x200; return address = 0x11
        // load_gpr_from_mem(4'd4, 32'h00000200);
        // DUT.memory_unit.mem_array[9'h10] = j_instr(OP_JAL, 4'd4);
        // run_fetch_T0_T2(32'h10);
        // run_jal_T3_T4();
        // expect32(R12, 32'h00000011, "3.5 jal R4 (R12=PC+1)");
        // expect32(PC_val, 32'h00000200, "3.5 jal R4 (PC=R4)");

        // $display("\n=== 3.6 mfhi / mflo ===");

        // load_hi_from_mem(32'hAAAABBBB);
        // load_lo_from_mem(32'hCCCCDDDD);
        // DUT.memory_unit.mem_array[9'h90] = j_instr(OP_MFHI, 4'd5);
        // run_fetch_T0_T2(32'h90);
        // run_mfhi_T3();
        // expect32(R5, 32'hAAAABBBB, "3.6 mfhi R5");

        // DUT.memory_unit.mem_array[9'h91] = j_instr(OP_MFLO, 4'd1);
        // run_fetch_T0_T2(32'h91);
        // run_mflo_T3();
        // expect32(R1, 32'hCCCCDDDD, "3.6 mflo R1");

        // $display("\n=== 3.7 Input / Output ===");

        // input_port = 32'h00FACADE;
        // DUT.memory_unit.mem_array[9'hA0] = j_instr(OP_IN, 4'd5);
        // run_fetch_T0_T2(32'hA0);
        // run_in_T3();
        // expect32(R5, 32'h00FACADE, "3.7 in R5");

        // load_gpr_from_mem(4'd7, 32'h76543210);
        // DUT.memory_unit.mem_array[9'hA1] = j_instr(OP_OUT, 4'd7);
        // run_fetch_T0_T2(32'hA1);
        // run_out_T3();
        // expect32(output_port, 32'h76543210, "3.7 out R7");

        if (errors == 0)
            $display("\n*** Section 3 Phase2_tb: ALL TESTS PASSED ***\n");
        else
            $display("\n*** Section 3 Phase2_tb: %0d FAILURE(S) ***\n", errors);

        $finish;
    end
endmodule
