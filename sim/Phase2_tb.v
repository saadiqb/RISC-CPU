`timescale 1ns / 10ps

module Phase2_tb;
    // --- Clock and Reset ---
    reg clock, clear;
    
    // --- Select and Encode Control Signals ---
    reg Gra, Grb, Grc, Rin_ctrl, Rout_ctrl, BAout;
    
    // --- Core Datapath Signals ---
    reg PCin, PCout, IncPC, IRin, Yin, Zin, HIin, LOin, MARin, MDRin, MDRout;
    reg Read, Write, Zhighout, Zlowout, HIout, LOout, Cout;
    
    // --- Branching and I/O ---
    reg CONin, OutPortin, InPortin;
    reg [31:0] in_port_data;
    wire [31:0] out_port_data, BusMuxOut_out;
    wire CON_out;
    
   // --- ALU ---
    reg [4:0] ALU_op;
    
    // CORRECTED: Matches localparams in ALU.v
    parameter ADD_OP = 5'd0;
    parameter AND_OP = 5'd9;
    parameter OR_OP  = 5'd10;

    // --- Instantiate the Datapath ---
    DataPath DUT (
        .clock(clock), .clear(clear),
        .Gra(Gra), .Grb(Grb), .Grc(Grc), .Rin_ctrl(Rin_ctrl), .Rout_ctrl(Rout_ctrl), .BAout(BAout),
        .PCin(PCin), .PCout(PCout), .IncPC(IncPC), .IRin(IRin), .Yin(Yin), .Zin(Zin), 
        .HIin(HIin), .LOin(LOin), .MARin(MARin), .MDRin(MDRin), .MDRout(MDRout),
        .Read(Read), .Write(Write), 
        .Zhighout(Zhighout), .Zlowout(Zlowout), .HIout(HIout), .LOout(LOout), .Cout(Cout),
        .InPortout(InPortout), .CONin(CONin), .OutPortin(OutPortin), .InPortin(InPortin),
        .in_port_data(in_port_data), .out_port_data(out_port_data), .CON_out(CON_out),
        .ALU_op(ALU_op), .BusMuxOut_out(BusMuxOut_out)
    );

    // --- Clock Generation ---
    initial begin
        clock = 0;
        forever #10 clock = ~clock; // 20ns period
    end

    // --- Helper Task to clear signals after each cycle ---
    task Reset_Signals;
        begin
            Gra=0; Grb=0; Grc=0; Rin_ctrl=0; Rout_ctrl=0; BAout=0;
            PCin=0; PCout=0; IncPC=0; IRin=0; Yin=0; Zin=0; HIin=0; LOin=0;
            MARin=0; MDRin=0; MDRout=0; Read=0; Write=0;
            Zhighout=0; Zlowout=0; HIout=0; LOout=0; Cout=0;
            CONin=0; OutPortin=0; InPortin=0; InPortout=0;
            ALU_op = 5'b00000;
        end
    endtask

    // =========================================================================
    // MAIN SIMULATION BLOCK (Uncomment ONE test at a time)
    // =========================================================================
    initial begin
        Reset_Signals();
        clear = 1; #20; clear = 0; // Trigger system reset

        // =====================================================================
        // SECTION 3.1: LOAD INSTRUCTIONS
        // =====================================================================
        
        // ---------------------------------------------------------------------
        // TEST 3.1 - Case 1: ld R7, 0x65
        // ---------------------------------------------------------------------
        /*
        $display("--- Starting Test 3.1 Case 1: ld R7, 0x65 ---");
        DUT.memory_unit.memory[9'h065] = 32'h00000084;
        DUT.memory_unit.memory[0] = {5'b00000, 4'b0111, 4'b0000, 19'h00065}; // ld R7, R0, 0x65
        DUT.PC.q = 32'd0;

        PCout=1; MARin=1; IncPC=1; Zin=1; #20; Reset_Signals();
        Zlowout=1; PCin=1; Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; IRin=1; #20; Reset_Signals();
        Grb=1; BAout=1; Yin=1; #20; Reset_Signals();
        Cout=1; ALU_op=ADD_OP; Zin=1; #20; Reset_Signals();
        Zlowout=1; MARin=1; #20; Reset_Signals();
        Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; Gra=1; Rin_ctrl=1; #20; Reset_Signals();
        #20; $stop;
        */

        // ---------------------------------------------------------------------
        // TEST 3.1 - Case 2: ld R0, 0x72(R2)
        // ---------------------------------------------------------------------
        /*
        $display("--- Starting Test 3.1 Case 2: ld R0, 0x72(R2) ---");
        DUT.R2.q = 32'h00000057;
        DUT.memory_unit.memory[9'h0C9] = 32'h0000002B; // 0x57 + 0x72 = 0xC9
        DUT.memory_unit.memory[0] = {5'b00000, 4'b0000, 4'b0010, 19'h00072}; // ld R0, R2, 0x72
        DUT.PC.q = 32'd0;

        PCout=1; MARin=1; IncPC=1; Zin=1; #20; Reset_Signals();
        Zlowout=1; PCin=1; Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; IRin=1; #20; Reset_Signals();
        Grb=1; BAout=1; Yin=1; #20; Reset_Signals(); // BAout evaluates R2
        Cout=1; ALU_op=ADD_OP; Zin=1; #20; Reset_Signals();
        Zlowout=1; MARin=1; #20; Reset_Signals();
        Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; Gra=1; Rin_ctrl=1; #20; Reset_Signals();
        #20; $stop;
        */

        // ---------------------------------------------------------------------
        // TEST 3.1 - Case 3: ldi R7, 0x65
        // ---------------------------------------------------------------------
        /*
        $display("--- Starting Test 3.1 Case 3: ldi R7, 0x65 ---");
        DUT.memory_unit.memory[0] = {5'b00000, 4'b0111, 4'b0000, 19'h00065}; // ldi R7, R0, 0x65
        DUT.PC.q = 32'd0;

        PCout=1; MARin=1; IncPC=1; Zin=1; #20; Reset_Signals();
        Zlowout=1; PCin=1; Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; IRin=1; #20; Reset_Signals();
        Grb=1; BAout=1; Yin=1; #20; Reset_Signals();
        Cout=1; ALU_op=ADD_OP; Zin=1; #20; Reset_Signals();
        Zlowout=1; Gra=1; Rin_ctrl=1; #20; Reset_Signals();
        #20; $stop;
        */

        // ---------------------------------------------------------------------
        // TEST 3.1 - Case 4: ldi R0, 0x72(R2)
        // ---------------------------------------------------------------------
        /*
        $display("--- Starting Test 3.1 Case 4: ldi R0, 0x72(R2) ---");
        DUT.R2.q = 32'h00000057;
        DUT.memory_unit.memory[0] = {5'b00000, 4'b0000, 4'b0010, 19'h00072}; // ldi R0, R2, 0x72
        DUT.PC.q = 32'd0;

        PCout=1; MARin=1; IncPC=1; Zin=1; #20; Reset_Signals();
        Zlowout=1; PCin=1; Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; IRin=1; #20; Reset_Signals();
        Grb=1; BAout=1; Yin=1; #20; Reset_Signals();
        Cout=1; ALU_op=ADD_OP; Zin=1; #20; Reset_Signals();
        Zlowout=1; Gra=1; Rin_ctrl=1; #20; Reset_Signals();
        #20; $stop;
        */

        // =====================================================================
        // SECTION 3.2: STORE INSTRUCTION
        // =====================================================================

        // ---------------------------------------------------------------------
        // TEST 3.2 - Case 1: st 0x1F, R6
        // ---------------------------------------------------------------------
        /*
        $display("--- Starting Test 3.2 Case 1: st 0x1F, R6 ---");
        DUT.R6.q = 32'h00000063; 
        DUT.memory_unit.memory[9'h01F] = 32'h000000D4; // Dummy data to be overwritten
        DUT.memory_unit.memory[0] = {5'b00000, 4'b0110, 4'b0000, 19'h0001F}; // st R6, R0, 0x1F
        DUT.PC.q = 32'd0;

        PCout=1; MARin=1; IncPC=1; Zin=1; #20; Reset_Signals();
        Zlowout=1; PCin=1; Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; IRin=1; #20; Reset_Signals();
        Grb=1; BAout=1; Yin=1; #20; Reset_Signals();
        Cout=1; ALU_op=ADD_OP; Zin=1; #20; Reset_Signals();
        Zlowout=1; MARin=1; #20; Reset_Signals();
        Gra=1; Rout_ctrl=1; MDRin=1; #20; Reset_Signals();
        Write=1; #20; Reset_Signals();
        #20; $stop;
        */

        // ---------------------------------------------------------------------
        // TEST 3.2 - Case 2: st 0x1F(R6), R6
        // ---------------------------------------------------------------------
        /*
        $display("--- Starting Test 3.2 Case 2: st 0x1F(R6), R6 ---");
        DUT.R6.q = 32'h00000063; 
        DUT.memory_unit.memory[9'h082] = 32'h000000A7; // Dummy data (0x1F + 0x63 = 0x82)
        DUT.memory_unit.memory[0] = {5'b00000, 4'b0110, 4'b0110, 19'h0001F}; // st R6, R6, 0x1F
        DUT.PC.q = 32'd0;

        PCout=1; MARin=1; IncPC=1; Zin=1; #20; Reset_Signals();
        Zlowout=1; PCin=1; Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; IRin=1; #20; Reset_Signals();
        Grb=1; BAout=1; Yin=1; #20; Reset_Signals(); // BAout routes R6 to bus
        Cout=1; ALU_op=ADD_OP; Zin=1; #20; Reset_Signals();
        Zlowout=1; MARin=1; #20; Reset_Signals();
        Gra=1; Rout_ctrl=1; MDRin=1; #20; Reset_Signals();
        Write=1; #20; Reset_Signals();
        #20; $stop;
        */

        // =====================================================================
        // SECTION 3.3: ALU IMMEDIATE INSTRUCTIONS
        // =====================================================================

        // ---------------------------------------------------------------------
        // TEST 3.3 - addi R7, R4, -9
        // ---------------------------------------------------------------------
        /*
        $display("--- Starting Test 3.3: addi R7, R4, -9 ---");
        DUT.R4.q = 32'h00000010; // 16 + -9 = 7
        DUT.memory_unit.memory[0] = {5'b00000, 4'b0111, 4'b0100, 19'h7FFF7}; // -9 is 19'h7FFF7
        DUT.PC.q = 32'd0;

        PCout=1; MARin=1; IncPC=1; Zin=1; #20; Reset_Signals();
        Zlowout=1; PCin=1; Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; IRin=1; #20; Reset_Signals();
        Grb=1; Rout_ctrl=1; Yin=1; #20; Reset_Signals();
        Cout=1; ALU_op=ADD_OP; Zin=1; #20; Reset_Signals();
        Zlowout=1; Gra=1; Rin_ctrl=1; #20; Reset_Signals();
        #20; $stop;
        */

        // ---------------------------------------------------------------------
        // TEST 3.3 - andi R7, R4, 0x71
        // ---------------------------------------------------------------------
        /*
        $display("--- Starting Test 3.3: andi R7, R4, 0x71 ---");
        DUT.R4.q = 32'h000000F0;
        DUT.memory_unit.memory[0] = {5'b00000, 4'b0111, 4'b0100, 19'h00071}; 
        DUT.PC.q = 32'd0;

        PCout=1; MARin=1; IncPC=1; Zin=1; #20; Reset_Signals();
        Zlowout=1; PCin=1; Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; IRin=1; #20; Reset_Signals();
        Grb=1; Rout_ctrl=1; Yin=1; #20; Reset_Signals();
        Cout=1; ALU_op=AND_OP; Zin=1; #20; Reset_Signals();
        Zlowout=1; Gra=1; Rin_ctrl=1; #20; Reset_Signals();
        #20; $stop;
        */

        // ---------------------------------------------------------------------
        // TEST 3.3 - ori R7, R4, 0x71
        // ---------------------------------------------------------------------
        /*
        $display("--- Starting Test 3.3: ori R7, R4, 0x71 ---");
        DUT.R4.q = 32'h00000000;
        DUT.memory_unit.memory[0] = {5'b00000, 4'b0111, 4'b0100, 19'h00071}; 
        DUT.PC.q = 32'd0;

        PCout=1; MARin=1; IncPC=1; Zin=1; #20; Reset_Signals();
        Zlowout=1; PCin=1; Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; IRin=1; #20; Reset_Signals();
        Grb=1; Rout_ctrl=1; Yin=1; #20; Reset_Signals();
        Cout=1; ALU_op=OR_OP; Zin=1; #20; Reset_Signals();
        Zlowout=1; Gra=1; Rin_ctrl=1; #20; Reset_Signals();
        #20; $stop;
        */

        // =====================================================================
        // SECTION 3.4: BRANCH INSTRUCTIONS (Testing TAKEN conditions)
        // =====================================================================

        // ---------------------------------------------------------------------
        // TEST 3.4 - brzr R3, 48 (Branch if Zero)
        // ---------------------------------------------------------------------
        /*
        $display("--- Starting Test 3.4: brzr R3, 48 ---");
        DUT.R3.q = 32'd0; // R3 = 0, will be TAKEN
        DUT.memory_unit.memory[0] = {5'b00000, 4'b0011, 4'b0000, 19'h00030}; // 48 is 0x30
        DUT.PC.q = 32'd0;

        PCout=1; MARin=1; IncPC=1; Zin=1; #20; Reset_Signals();
        Zlowout=1; PCin=1; Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; IRin=1; #20; Reset_Signals();
        Gra=1; Rout_ctrl=1; CONin=1; #20; Reset_Signals();
        PCout=1; Yin=1; #20; Reset_Signals();
        Cout=1; ALU_op=ADD_OP; Zin=1; #20; Reset_Signals();
        Zlowout=1; if (CON_out) PCin = 1; #20; Reset_Signals();
        #20; $stop;
        */

        // ---------------------------------------------------------------------
        // TEST 3.4 - brnz R3, 48 (Branch if Not Zero)
        // ---------------------------------------------------------------------
        /*
        $display("--- Starting Test 3.4: brnz R3, 48 ---");
        DUT.R3.q = 32'd5; // R3 != 0, will be TAKEN
        DUT.memory_unit.memory[0] = {5'b00000, 4'b0011, 4'b0100, 19'h00030}; // C2 = 01
        DUT.PC.q = 32'd0;

        PCout=1; MARin=1; IncPC=1; Zin=1; #20; Reset_Signals();
        Zlowout=1; PCin=1; Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; IRin=1; #20; Reset_Signals();
        Gra=1; Rout_ctrl=1; CONin=1; #20; Reset_Signals();
        PCout=1; Yin=1; #20; Reset_Signals();
        Cout=1; ALU_op=ADD_OP; Zin=1; #20; Reset_Signals();
        Zlowout=1; if (CON_out) PCin = 1; #20; Reset_Signals();
        #20; $stop;
        */

        // ---------------------------------------------------------------------
        // TEST 3.4 - brpl R3, 48 (Branch if Positive)
        // ---------------------------------------------------------------------
        /*
        $display("--- Starting Test 3.4: brpl R3, 48 ---");
        DUT.R3.q = 32'd5; // R3 >= 0, will be TAKEN
        DUT.memory_unit.memory[0] = {5'b00000, 4'b0011, 4'b1000, 19'h00030}; // C2 = 10
        DUT.PC.q = 32'd0;

        PCout=1; MARin=1; IncPC=1; Zin=1; #20; Reset_Signals();
        Zlowout=1; PCin=1; Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; IRin=1; #20; Reset_Signals();
        Gra=1; Rout_ctrl=1; CONin=1; #20; Reset_Signals();
        PCout=1; Yin=1; #20; Reset_Signals();
        Cout=1; ALU_op=ADD_OP; Zin=1; #20; Reset_Signals();
        Zlowout=1; if (CON_out) PCin = 1; #20; Reset_Signals();
        #20; $stop;
        */

        // ---------------------------------------------------------------------
        // TEST 3.4 - brmi R3, 48 (Branch if Minus/Negative)
        // ---------------------------------------------------------------------
        /*
        $display("--- Starting Test 3.4: brmi R3, 48 ---");
        DUT.R3.q = 32'hFFFFFFFF; // R3 < 0, will be TAKEN
        DUT.memory_unit.memory[0] = {5'b00000, 4'b0011, 4'b1100, 19'h00030}; // C2 = 11
        DUT.PC.q = 32'd0;

        PCout=1; MARin=1; IncPC=1; Zin=1; #20; Reset_Signals();
        Zlowout=1; PCin=1; Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; IRin=1; #20; Reset_Signals();
        Gra=1; Rout_ctrl=1; CONin=1; #20; Reset_Signals();
        PCout=1; Yin=1; #20; Reset_Signals();
        Cout=1; ALU_op=ADD_OP; Zin=1; #20; Reset_Signals();
        Zlowout=1; if (CON_out) PCin = 1; #20; Reset_Signals();
        #20; $stop;
        */

        // =====================================================================
        // SECTION 3.5: JUMP INSTRUCTIONS
        // =====================================================================

        // ---------------------------------------------------------------------
        // TEST 3.5 - jr R12
        // ---------------------------------------------------------------------
        /*
        $display("--- Starting Test 3.5: jr R12 ---");
        DUT.R12.q = 32'h000000FF; 
        DUT.PC.q = 32'h00000010;
        DUT.memory_unit.memory[9'h010] = {5'b00000, 4'b1100, 4'b0000, 19'h00000}; 

        PCout=1; MARin=1; IncPC=1; Zin=1; #20; Reset_Signals();
        Zlowout=1; PCin=1; Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; IRin=1; #20; Reset_Signals();
        Gra=1; Rout_ctrl=1; PCin=1; #20; Reset_Signals();
        #20; $stop;
        */

        // ---------------------------------------------------------------------
        // TEST 3.5 - jal R4
        // ---------------------------------------------------------------------
        /*
        $display("--- Starting Test 3.5: jal R4 ---");
        DUT.R4.q = 32'h000000AA; 
        DUT.PC.q = 32'h00000010;
        // Instruction packs R4 in Gra and R12 in Grb (for RA save)
        DUT.memory_unit.memory[9'h010] = {5'b00000, 4'b0100, 4'b1100, 19'h00000}; 

        PCout=1; MARin=1; IncPC=1; Zin=1; #20; Reset_Signals();
        Zlowout=1; PCin=1; Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; IRin=1; #20; Reset_Signals();
        
        // Save PC to RA (R12 using Grb)
        PCout=1; Grb=1; Rin_ctrl=1; #20; Reset_Signals();
        // Jump to R4 (using Gra)
        Gra=1; Rout_ctrl=1; PCin=1; #20; Reset_Signals();
        #20; $stop;
        */

        // =====================================================================
        // SECTION 3.6: SPECIAL INSTRUCTIONS
        // =====================================================================

        // ---------------------------------------------------------------------
        // TEST 3.6 - mfhi R5
        // ---------------------------------------------------------------------
        /*
        $display("--- Starting Test 3.6: mfhi R5 ---");
        DUT.HI.q = 32'h12345678;
        DUT.PC.q = 32'd0;
        DUT.memory_unit.memory[0] = {5'b00000, 4'b0101, 4'b0000, 19'h00000}; 

        PCout=1; MARin=1; IncPC=1; Zin=1; #20; Reset_Signals();
        Zlowout=1; PCin=1; Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; IRin=1; #20; Reset_Signals();
        HIout=1; Gra=1; Rin_ctrl=1; #20; Reset_Signals();
        #20; $stop;
        */

        // ---------------------------------------------------------------------
        // TEST 3.6 - mflo R1
        // ---------------------------------------------------------------------
        /*
        $display("--- Starting Test 3.6: mflo R1 ---");
        DUT.LO.q = 32'h87654321;
        DUT.PC.q = 32'd0;
        DUT.memory_unit.memory[0] = {5'b00000, 4'b0001, 4'b0000, 19'h00000}; 

        PCout=1; MARin=1; IncPC=1; Zin=1; #20; Reset_Signals();
        Zlowout=1; PCin=1; Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; IRin=1; #20; Reset_Signals();
        LOout=1; Gra=1; Rin_ctrl=1; #20; Reset_Signals();
        #20; $stop;
        */

        // =====================================================================
        // SECTION 3.7: INPUT/OUTPUT INSTRUCTIONS
        // =====================================================================

        // ---------------------------------------------------------------------
        // TEST 3.7 - out R7
        // ---------------------------------------------------------------------
        /*
        $display("--- Starting Test 3.7: out R7 ---");
        DUT.R7.q = 32'hBEEFBEEF; 
        DUT.PC.q = 32'd0;
        DUT.memory_unit.memory[0] = {5'b00000, 4'b0111, 4'b0000, 19'h00000}; 

        PCout=1; MARin=1; IncPC=1; Zin=1; #20; Reset_Signals();
        Zlowout=1; PCin=1; Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; IRin=1; #20; Reset_Signals();
        Gra=1; Rout_ctrl=1; OutPortin=1; #20; Reset_Signals();
        #20; $stop;
        */

        // ---------------------------------------------------------------------
        // TEST 3.7 - in R5
        // ---------------------------------------------------------------------
        /*
        $display("--- Starting Test 3.7: in R5 ---");
        in_port_data = 32'hCAFEBA5E; // Data from external environment
        InPortin = 1; #20; InPortin = 0; // Strobe data into InPort
        
        DUT.PC.q = 32'd0;
        DUT.memory_unit.memory[0] = {5'b00000, 4'b0101, 4'b0000, 19'h00000}; 

        PCout=1; MARin=1; IncPC=1; Zin=1; #20; Reset_Signals();
        Zlowout=1; PCin=1; Read=1; MDRin=1; #20; Reset_Signals();
        MDRout=1; IRin=1; #20; Reset_Signals();
        InPortout=1; Gra=1; Rin_ctrl=1; #20; Reset_Signals();
        #20; $stop;
        */
        
    end
endmodule