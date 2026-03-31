`timescale 1ns/10ps

module Phase4_tb;

    reg clock;
    reg reset;
    reg stop;
    reg [31:0] in_port_data;
    wire [31:0] out_port_data;
    wire [31:0] BusMuxOut_out;
    wire [31:0] mem_089;
    wire [31:0] mem_0A3;
    wire [31:0] mem_088;
    wire [31:0] IR;
    wire [31:0] PC;
    wire [31:0] MDR;
    wire [31:0] MAR;
    wire [31:0] HI;
    wire [31:0] LO;
    wire [31:0] R0;
    wire [31:0] R1;
    wire [31:0] R2;
    wire [31:0] R3;
    wire [31:0] R4;
    wire [31:0] R5;
    wire [31:0] R6;
    wire [31:0] R7;
    wire [31:0] R8;
    wire [31:0] R9;
    wire [31:0] R10;
    wire [31:0] R11;
    wire [31:0] R12;
    wire [31:0] R13;
    wire [31:0] R14;
    wire [31:0] R15;
    wire [31:0] Y;
    wire [63:0] Z;
    wire [31:0] BusMuxOut;
    wire CON;
    wire Run;
    wire IRin_sig;
    wire MARin_sig;
    wire Zin_sig;
    integer inst_log;
    integer window_cycles;
    integer window_left;
    reg target_mode;
    reg match_on_ir;
    reg match_on_addr;
    reg match_on_pc;
    reg dump_active;
    reg [31:0] target_ir;
    reg [31:0] target_addr;
    reg [31:0] target_pc;
    reg [8*128:1] dumpfile;

    // Opcode definitions (match control_unit.v)
    localparam INST_ADD  = 5'b00000;
    localparam INST_SUB  = 5'b00001;
    localparam INST_AND  = 5'b00010;
    localparam INST_OR   = 5'b00011;
    localparam INST_SHR  = 5'b00100;
    localparam INST_SHRA = 5'b00101;
    localparam INST_SHL  = 5'b00110;
    localparam INST_ROR  = 5'b00111;
    localparam INST_ROL  = 5'b01000;
    localparam INST_NEG  = 5'b01001;
    localparam INST_NOT  = 5'b01010;
    localparam INST_MUL  = 5'b01011;
    localparam INST_DIV  = 5'b01100;
    localparam INST_LDI  = 5'b01101;
    localparam INST_LD   = 5'b01110;
    localparam INST_ST   = 5'b01111;
    localparam INST_ADDI = 5'b10000;
    localparam INST_ANDI = 5'b10001;
    localparam INST_ORI  = 5'b10010;
    localparam INST_BRMI = 5'b10011;
    localparam INST_BRPL = 5'b10100;
    localparam INST_MFHI = 5'b10101;
    localparam INST_MFLO = 5'b10110;
    localparam INST_JAL  = 5'b10111;
    localparam INST_JR   = 5'b11000;
    localparam INST_IN   = 5'b11001;
    localparam INST_OUT  = 5'b11010;
    localparam INST_NOP  = 5'b11110;
    localparam INST_HALT = 5'b11111;

    // Instantiate Top-Level CPU
    cpu DUT (
        .clock(clock),
        .reset(reset),
        .stop(stop),
        .in_port_data(in_port_data),
        .out_port_data(out_port_data),
        .BusMuxOut_out(BusMuxOut_out)
    );

    // Memory taps for waveform visibility (required memory locations)
    assign mem_089 = DUT.datapath_inst.memory_unit.memory[9'h089];
    assign mem_0A3 = DUT.datapath_inst.memory_unit.memory[9'h0A3];
    assign mem_088 = DUT.datapath_inst.memory_unit.memory[9'h088];

    // Short alias signals for GTKWave readability
    assign IR  = DUT.datapath_inst.IR_data;
    assign PC  = DUT.datapath_inst.PC_data;
    assign MDR = DUT.datapath_inst.MDR_data;
    assign MAR = DUT.datapath_inst.MAR_data;
    assign HI  = DUT.datapath_inst.HI_data;
    assign LO  = DUT.datapath_inst.LO_data;
    assign R0  = DUT.datapath_inst.R0.q;
    assign R1  = DUT.datapath_inst.R1.q;
    assign R2  = DUT.datapath_inst.R2.q;
    assign R3  = DUT.datapath_inst.R3.q;
    assign R4  = DUT.datapath_inst.R4.q;
    assign R5  = DUT.datapath_inst.R5.q;
    assign R6  = DUT.datapath_inst.R6.q;
    assign R7  = DUT.datapath_inst.R7.q;
    assign R8  = DUT.datapath_inst.R8.q;
    assign R9  = DUT.datapath_inst.R9.q;
    assign R10 = DUT.datapath_inst.R10.q;
    assign R11 = DUT.datapath_inst.R11.q;
    assign R12 = DUT.datapath_inst.R12.q;
    assign R13 = DUT.datapath_inst.R13.q;
    assign R14 = DUT.datapath_inst.R14.q;
    assign R15 = DUT.datapath_inst.R15.q;
    assign Y = DUT.datapath_inst.Y_data;
    assign Z = DUT.datapath_inst.Z_data;
    assign BusMuxOut = DUT.BusMuxOut_out;
    assign CON = DUT.CON_out;
    assign Run = DUT.cu_inst.run_flag;
    assign IRin_sig = DUT.cu_inst.IRin;
    assign MARin_sig = DUT.cu_inst.MARin;
    assign Zin_sig = DUT.cu_inst.Zin;

    // Clock Generation (Period = 20ns)
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    // GTKWave dumpfile (minimal required signals with short aliases)
    initial begin
        dumpfile = "sim/phase4_tb_min.vcd";
        window_cycles = 8;
        target_mode = 0;
        match_on_ir = 0;
        match_on_addr = 0;
        match_on_pc = 0;
        dump_active = 0;

        // Optional runtime controls:
        //   +dump=<file.vcd>     choose output VCD name
        //   +window=<cycles>     number of cycles to capture after match
        //   +ir=<hex>            match IR value
        //   +addr=<hex>          match MAR (instruction address)
        //   +pc=<hex>            match PC (next PC during IRin)
        $value$plusargs("dump=%s", dumpfile);
        $value$plusargs("window=%d", window_cycles);
        if ($value$plusargs("ir=%h", target_ir)) begin
            target_mode = 1;
            match_on_ir = 1;
        end
        if ($value$plusargs("addr=%h", target_addr)) begin
            target_mode = 1;
            match_on_addr = 1;
        end
        if ($value$plusargs("pc=%h", target_pc)) begin
            target_mode = 1;
            match_on_pc = 1;
        end
        if (window_cycles < 1) window_cycles = 1;

        $dumpfile(dumpfile);
        $dumpvars(0,
            Phase4_tb.clock,
            Phase4_tb.reset,
            Phase4_tb.stop,
            Phase4_tb.in_port_data,
            Phase4_tb.out_port_data,
            Phase4_tb.IR,
            Phase4_tb.PC,
            Phase4_tb.MDR,
            Phase4_tb.MAR,
            Phase4_tb.HI,
            Phase4_tb.LO,
            Phase4_tb.R0,
            Phase4_tb.R1,
            Phase4_tb.R2,
            Phase4_tb.R3,
            Phase4_tb.R4,
            Phase4_tb.R5,
            Phase4_tb.R6,
            Phase4_tb.R7,
            Phase4_tb.R8,
            Phase4_tb.R9,
            Phase4_tb.R10,
            Phase4_tb.R11,
            Phase4_tb.R12,
            Phase4_tb.R13,
            Phase4_tb.R14,
            Phase4_tb.R15,
            Phase4_tb.Y,
            Phase4_tb.Z,
            Phase4_tb.BusMuxOut,
            Phase4_tb.CON,
            Phase4_tb.Run,
            Phase4_tb.IRin_sig,
            Phase4_tb.MARin_sig,
            Phase4_tb.Zin_sig,
            Phase4_tb.mem_089,
            Phase4_tb.mem_0A3,
            Phase4_tb.mem_088
        );

        // If targeting a specific instruction window, start with dumping off.
        if (target_mode) begin
            $dumpoff;
        end
    end

    // Log instruction windows for manual zooming in GTKWave
    function [8*12:1] inst_name;
        input [4:0] op;
        begin
            case (op)
                INST_ADD:  inst_name = "add";
                INST_SUB:  inst_name = "sub";
                INST_AND:  inst_name = "and";
                INST_OR:   inst_name = "or";
                INST_SHR:  inst_name = "shr";
                INST_SHRA: inst_name = "shra";
                INST_SHL:  inst_name = "shl";
                INST_ROR:  inst_name = "ror";
                INST_ROL:  inst_name = "rol";
                INST_NEG:  inst_name = "neg";
                INST_NOT:  inst_name = "not";
                INST_MUL:  inst_name = "mul";
                INST_DIV:  inst_name = "div";
                INST_LDI:  inst_name = "ldi";
                INST_LD:   inst_name = "ld";
                INST_ST:   inst_name = "st";
                INST_ADDI: inst_name = "addi";
                INST_ANDI: inst_name = "andi";
                INST_ORI:  inst_name = "ori";
                INST_BRMI: inst_name = "brmi";
                INST_BRPL: inst_name = "brpl";
                INST_MFHI: inst_name = "mfhi";
                INST_MFLO: inst_name = "mflo";
                INST_JAL:  inst_name = "jal";
                INST_JR:   inst_name = "jr";
                INST_IN:   inst_name = "in";
                INST_OUT:  inst_name = "out";
                INST_NOP:  inst_name = "nop";
                INST_HALT: inst_name = "halt";
                default:   inst_name = "unknown";
            endcase
        end
    endfunction

    function integer inst_cycles;
        input [4:0] op;
        begin
            case (op)
                INST_LD, INST_ST: inst_cycles = 6;
                INST_BRMI, INST_BRPL: inst_cycles = 5;
                INST_MUL, INST_DIV: inst_cycles = 5;
                INST_JAL: inst_cycles = 3;
                INST_IN:  inst_cycles = 3;
                INST_MFHI, INST_MFLO, INST_JR, INST_OUT: inst_cycles = 2;
                INST_NOP, INST_HALT: inst_cycles = 1;
                default: inst_cycles = 4; // ALU, ALUI, LDI
            endcase
        end
    endfunction

    initial begin
        inst_log = $fopen("sim/phase4_inst_windows.txt", "w");
        $fdisplay(inst_log, "start_ns,end_ns,pc,ir,op,cycles");
    end

    always @(posedge clock) begin
        if (DUT.datapath_inst.IRin) begin
            integer cycles;
            cycles = inst_cycles(DUT.datapath_inst.IR_data[31:27]);
            $fdisplay(inst_log, "%0t,%0t,0x%08h,0x%08h,%s,%0d",
                $time,
                $time + (cycles * 20),
                DUT.datapath_inst.PC_data,
                DUT.datapath_inst.IR_data,
                inst_name(DUT.datapath_inst.IR_data[31:27]),
                cycles
            );
        end
    end

    // Targeted VCD capture for a single instruction window
    always @(posedge clock) begin
        if (target_mode) begin
            if (!dump_active) begin
                if (DUT.datapath_inst.IRin) begin
                    if ((match_on_ir && DUT.datapath_inst.IR_data == target_ir) ||
                        (match_on_addr && DUT.datapath_inst.MAR_data == target_addr) ||
                        (match_on_pc && DUT.datapath_inst.PC_data == target_pc)) begin
                        dump_active <= 1;
                        window_left <= window_cycles;
                        $dumpon;
                    end
                end
            end else begin
                if (window_left > 0) begin
                    window_left <= window_left - 1;
                end
                if (window_left <= 1) begin
                    $dumpoff;
                    $finish;
                end
            end
        end
    end

    // Simulation Sequence
    initial begin
        // Memory Initilization
        DUT.datapath_inst.memory_unit.memory[9'h089] = 32'h000000A7;
        DUT.datapath_inst.memory_unit.memory[9'h0A3] = 32'h00000068;
        DUT.datapath_inst.memory_unit.memory[9'h088] = 32'h0000FFFF;

        // --- Phase 3 Program (Addresses 0x000 - 0x028) ---
        DUT.datapath_inst.memory_unit.memory[9'h000] = 32'h6A800043; // ldi R5, 0x43
        DUT.datapath_inst.memory_unit.memory[9'h001] = 32'h6AA80006; // ldi R5, 6(R5)
        DUT.datapath_inst.memory_unit.memory[9'h002] = 32'h72000089; // ld  R4, 0x89
        DUT.datapath_inst.memory_unit.memory[9'h003] = 32'h6A200004; // ldi R4, 4(R4)
        DUT.datapath_inst.memory_unit.memory[9'h004] = 32'h7027FFF8; // ld  R0, -8(R4)
        DUT.datapath_inst.memory_unit.memory[9'h005] = 32'h69000004; // ldi R2, 4
        DUT.datapath_inst.memory_unit.memory[9'h006] = 32'h6A800087; // ldi R5, 0x87
        
        // --- Branching Test 1 ---
        DUT.datapath_inst.memory_unit.memory[9'h007] = 32'h9A980003; // brmi R5, 3 (C2=11)
        DUT.datapath_inst.memory_unit.memory[9'h008] = 32'h6AA80005; // ldi R5, 5(R5)
        DUT.datapath_inst.memory_unit.memory[9'h009] = 32'h70A7FFFD; // ld  R1, -3(R5)
        DUT.datapath_inst.memory_unit.memory[9'h00A] = 32'hF0000000; // nop
        
        // --- Branching Test 2 ---
        DUT.datapath_inst.memory_unit.memory[9'h00B] = 32'hA0900002; // brpl R1, 2 (C2=10)
        DUT.datapath_inst.memory_unit.memory[9'h00C] = 32'h69A80007; // ldi R3, 7(R5) (Skipped)
        DUT.datapath_inst.memory_unit.memory[9'h00D] = 32'h6B9FFFFC; // ldi R7, -4(R3) (Skipped)
        
        // --- Target: ALU Operations ---
        DUT.datapath_inst.memory_unit.memory[9'h00E] = 32'h03A90000; // add  R7, R5, R2
        DUT.datapath_inst.memory_unit.memory[9'h00F] = 32'h80880003; // addi R1, R1, 3
        DUT.datapath_inst.memory_unit.memory[9'h010] = 32'h48880000; // neg  R1, R1
        DUT.datapath_inst.memory_unit.memory[9'h011] = 32'h50880000; // not  R1, R1
        DUT.datapath_inst.memory_unit.memory[9'h012] = 32'h8888000F; // andi R1, R1, 0xF
        DUT.datapath_inst.memory_unit.memory[9'h013] = 32'h3A010000; // ror  R4, R0, R2
        DUT.datapath_inst.memory_unit.memory[9'h014] = 32'h90A00005; // ori  R1, R4, 5
        DUT.datapath_inst.memory_unit.memory[9'h015] = 32'h2A090000; // shra R4, R1, R2
        DUT.datapath_inst.memory_unit.memory[9'h016] = 32'h22A90000; // shr  R5, R5, R2
        
        // --- Memory Operations ---
        DUT.datapath_inst.memory_unit.memory[9'h017] = 32'h7A8000A3; // st   0xA3, R5
        DUT.datapath_inst.memory_unit.memory[9'h018] = 32'h42810000; // rol  R5, R0, R2
        DUT.datapath_inst.memory_unit.memory[9'h019] = 32'h1B900000; // or   R7, R2, R0
        DUT.datapath_inst.memory_unit.memory[9'h01A] = 32'h12280000; // and  R4, R5, R0
        DUT.datapath_inst.memory_unit.memory[9'h01B] = 32'h7BA00089; // st   0x89(R4), R7
        DUT.datapath_inst.memory_unit.memory[9'h01C] = 32'h082B8000; // sub  R0, R5, R7
        DUT.datapath_inst.memory_unit.memory[9'h01D] = 32'h32290000; // shl  R4, R5, R2
        
        // --- Multiply & Divide Setup ---
        DUT.datapath_inst.memory_unit.memory[9'h01E] = 32'h6B800007; // ldi  R7, 7
        DUT.datapath_inst.memory_unit.memory[9'h01F] = 32'h69800019; // ldi  R3, 0x19
        DUT.datapath_inst.memory_unit.memory[9'h020] = 32'h59B80000; // mul  R3, R7
        DUT.datapath_inst.memory_unit.memory[9'h021] = 32'hA8800000; // mfhi R1
        DUT.datapath_inst.memory_unit.memory[9'h022] = 32'hB3000000; // mflo R6
        DUT.datapath_inst.memory_unit.memory[9'h023] = 32'h61B80000; // div  R3, R7
        
        // --- Procedure Setup ---
        DUT.datapath_inst.memory_unit.memory[9'h024] = 32'h6C380002; // ldi  R8,  2(R7)
        DUT.datapath_inst.memory_unit.memory[9'h025] = 32'h6C9FFFFC; // ldi  R9, -4(R3)
        DUT.datapath_inst.memory_unit.memory[9'h026] = 32'h6D300003; // ldi  R10, 3(R6)
        DUT.datapath_inst.memory_unit.memory[9'h027] = 32'h6D880005; // ldi  R11, 5(R1)
        
        // --- Jump and Link (Procedure Call) ---
        DUT.datapath_inst.memory_unit.memory[9'h028] = 32'hBE500000; // jal  R12, R10

        // --- Phase 4 Program (Addresses 0x029 - 0x03B) ---
        DUT.datapath_inst.memory_unit.memory[9'h029] = 32'hCB000000; // in   R6
        DUT.datapath_inst.memory_unit.memory[9'h02A] = 32'h7B000077; // st   0x77, R6
        DUT.datapath_inst.memory_unit.memory[9'h02B] = 32'h6980002E; // ldi  R3, 0x2E
        DUT.datapath_inst.memory_unit.memory[9'h02C] = 32'h6A800001; // ldi  R5, 1
        DUT.datapath_inst.memory_unit.memory[9'h02D] = 32'h69000028; // ldi  R2, 40
        DUT.datapath_inst.memory_unit.memory[9'h02E] = 32'hD3000000; // out  R6
        DUT.datapath_inst.memory_unit.memory[9'h02F] = 32'h6917FFFF; // ldi  R2, -1(R2)
        DUT.datapath_inst.memory_unit.memory[9'h030] = 32'h99000008; // brzr R2, 8
        DUT.datapath_inst.memory_unit.memory[9'h031] = 32'h73800088; // ld   R7, 0x88
        DUT.datapath_inst.memory_unit.memory[9'h032] = 32'h6BBFFFFF; // ldi  R7, -1(R7)
        DUT.datapath_inst.memory_unit.memory[9'h033] = 32'hF0000000; // nop
        DUT.datapath_inst.memory_unit.memory[9'h034] = 32'h9B8FFFFD; // brnz R7, -3
        DUT.datapath_inst.memory_unit.memory[9'h035] = 32'h23328000; // shr  R6, R6, R5
        DUT.datapath_inst.memory_unit.memory[9'h036] = 32'h9B0FFFF7; // brnz R6, -9
        DUT.datapath_inst.memory_unit.memory[9'h037] = 32'h73000077; // ld   R6, 0x77
        DUT.datapath_inst.memory_unit.memory[9'h038] = 32'hC1800000; // jr   R3
        DUT.datapath_inst.memory_unit.memory[9'h039] = 32'h6B000063; // ldi  R6, 0x63
        DUT.datapath_inst.memory_unit.memory[9'h03A] = 32'hD3000000; // out  R6
        DUT.datapath_inst.memory_unit.memory[9'h03B] = 32'hF8000000; // halt

        // 
        // PROCEDURE SUBA (Located at Address 0xB2)
        // 
        DUT.datapath_inst.memory_unit.memory[9'h0B2] = 32'h0F450000; // sub  R14, R8, R10
        DUT.datapath_inst.memory_unit.memory[9'h0B3] = 32'h0ECD8000; // sub  R13, R9, R11
        DUT.datapath_inst.memory_unit.memory[9'h0B4] = 32'h07768000; // add  R14, R14, R13
        DUT.datapath_inst.memory_unit.memory[9'h0B5] = 32'hC6000000; // jr   R12 (Return)

        // Initialize CPU control signals
        reset = 1;
        stop = 0;
        in_port_data = 32'h000000E0;
        
        #40;
        
        reset = 0;

        // Allow enough time to observe loop behavior.
        #2000000; 

        $finish;
    end
endmodule
