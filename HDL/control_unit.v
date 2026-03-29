`timescale 1ns/10ps

module control_unit(
    input wire clock, reset, stop,
    input wire [31:0] IR,
    input wire CON_out,
    
    // To DataPath
    output reg clear,
    output reg Gra, Grb, Grc,
    output reg Rin_ctrl, Rout_ctrl, BAout,
    output reg PCin, PCout, IncPC, IRin, Yin, Zin, HIin, LOin, MARin, MDRin, MDRout,
    output reg Read, Write,
    output reg Zhighout, Zlowout, HIout, LOout,
    output reg InPortout, Cout,
    output reg CONin, OutPortin, InPortin,
    output reg [4:0] ALU_op
);

    // --- State Encoding ---
    parameter Reset_State = 6'd0, Fetch0 = 6'd1, Fetch1 = 6'd2, Fetch2 = 6'd3;
    parameter ALU_3 = 6'd4, ALU_4 = 6'd5, ALU_5 = 6'd6; 
    parameter LDI_3 = 6'd7, LDI_4 = 6'd8, LDI_5 = 6'd9;
    parameter LD_3 = 6'd10, LD_4 = 6'd11, LD_5 = 6'd12, LD_6 = 6'd13, LD_7 = 6'd14;
    parameter ST_3 = 6'd15, ST_4 = 6'd16, ST_5 = 6'd17, ST_6 = 6'd18, ST_7 = 6'd19;
    parameter BR_3 = 6'd20, BR_4 = 6'd21, BR_5 = 6'd22, BR_6 = 6'd23;
    parameter HALT_State = 6'd63;

    // --- INSTRUCTION Opcodes (From IR[31:27]) ---
    localparam INST_ADD  = 5'b00000; 
    localparam INST_AND  = 5'b00010; 
    localparam INST_SUB  = 5'b00001;
    localparam INST_LDI  = 5'b01101; 
    localparam INST_LD   = 5'b01110; 
    localparam INST_ST   = 5'b01111; 
    localparam INST_BRMI = 5'b10001;
    localparam INST_BRPL = 5'b10010; 

    // --- ALU Opcodes ---
    localparam ALU_ADD  = 5'd0; 
    localparam ALU_SUB  = 5'd1; 
    localparam ALU_AND  = 5'd9; 
    // ... add other ALU opcodes here as needed for future instructions

    reg [5:0] present_state;
    reg run_flag;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            present_state <= Reset_State;
            run_flag <= 1'b1;
        end else if (stop || !run_flag) begin
            present_state <= HALT_State;
            run_flag <= 1'b0;
        end else begin
            case (present_state)
                Reset_State: present_state <= Fetch0;
                Fetch0: present_state <= Fetch1;
                Fetch1: present_state <= Fetch2;
                Fetch2: begin // Decode Instruction
                    case (IR[31:27])
                        INST_ADD, INST_AND, INST_SUB: present_state <= ALU_3;
                        INST_LDI: present_state <= LDI_3;
                        INST_LD: present_state <= LD_3;
                        INST_ST: present_state <= ST_3;
                        INST_BRMI, INST_BRPL: present_state <= BR_3;
                        default: present_state <= Fetch0; 
                    endcase
                end

                // Generic 3-Register ALU Ops
                ALU_3: present_state <= ALU_4;
                ALU_4: present_state <= ALU_5;
                ALU_5: present_state <= Fetch0;

                // Load Immediate
                LDI_3: present_state <= LDI_4;
                LDI_4: present_state <= LDI_5;
                LDI_5: present_state <= Fetch0;

                // Load from Memory
                LD_3: present_state <= LD_4;
                LD_4: present_state <= LD_5;
                LD_5: present_state <= LD_6;
                LD_6: present_state <= LD_7;
                LD_7: present_state <= Fetch0;
                
                // Store to Memory
                ST_3: present_state <= ST_4;
                ST_4: present_state <= ST_5;
                ST_5: present_state <= ST_6;
                ST_6: present_state <= ST_7;
                ST_7: present_state <= Fetch0;

                // Branching
                BR_3: present_state <= BR_4;
                BR_4: present_state <= BR_5;
                BR_5: present_state <= Fetch0;

                HALT_State: present_state <= HALT_State;
                default: present_state <= Reset_State;
            endcase
        end
    end

    // FSM Outputs
    always @(*) begin
        // 1. Default all signals to 0
        clear = 0; Gra = 0; Grb = 0; Grc = 0; Rin_ctrl = 0; Rout_ctrl = 0; BAout = 0;
        PCin = 0; PCout = 0; IncPC = 0; IRin = 0; Yin = 0; Zin = 0; HIin = 0; LOin = 0; 
        MARin = 0; MDRin = 0; MDRout = 0; Read = 0; Write = 0; Zhighout = 0; Zlowout = 0; 
        HIout = 0; LOout = 0; InPortout = 0; Cout = 0; CONin = 0; OutPortin = 0; InPortin = 0;
        ALU_op = 5'b00000;

        // 2. Assign outputs based on state
        case (present_state)
            Reset_State: begin
                clear = 1; 
            end
            Fetch0: begin
                PCout = 1; MARin = 1; IncPC = 1; Zin = 1;
            end
            Fetch1: begin
                Zlowout = 1; PCin = 1; Read = 1; MDRin = 1;
            end
            Fetch2: begin
                MDRout = 1; IRin = 1;
            end

            // --- 3-Reg ALU (e.g., ADD R1, R2, R3) ---
            ALU_3: begin
                Grb = 1; Rout_ctrl = 1; Yin = 1;
            end
            ALU_4: begin
                Grc = 1; Rout_ctrl = 1; Zin = 1;
                // **CRITICAL MAP:** Translate Instruction Opcode to ALU Opcode
                if (IR[31:27] == INST_ADD) ALU_op = ALU_ADD;
                else if (IR[31:27] == INST_AND) ALU_op = ALU_AND;
                else if (IR[31:27] == INST_SUB) ALU_op = ALU_SUB;
            end
            ALU_5: begin
                Zlowout = 1; Gra = 1; Rin_ctrl = 1;
            end

            // --- LDI (e.g., LDI R5, 0x43) ---
            LDI_3: begin
                Grb = 1; BAout = 1; Yin = 1; 
            end
            LDI_4: begin
                Cout = 1; ALU_op = ALU_ADD; Zin = 1; // Always ADD for address calculation
            end
            LDI_5: begin
                Zlowout = 1; Gra = 1; Rin_ctrl = 1;
            end

            // --- LD (Load) ---
            LD_3: begin
                Grb = 1; BAout = 1; Yin = 1;
            end
            LD_4: begin
                Cout = 1; ALU_op = ALU_ADD; Zin = 1; // Always ADD for address calculation
            end
            LD_5: begin
                Zlowout = 1; MARin = 1;
            end
            LD_6: begin
                Read = 1; MDRin = 1;
            end
            LD_7: begin
                MDRout = 1; Gra = 1; Rin_ctrl = 1;
            end

            // --- ST (Store) ---
            ST_3: begin
                Grb = 1; BAout = 1; Yin = 1;
            end
            ST_4: begin
                Cout = 1; ALU_op = ALU_ADD; Zin = 1; // Always ADD for address calculation
            end
            ST_5: begin
                Zlowout = 1; MARin = 1;
            end
            ST_6: begin
                Gra = 1; Rout_ctrl = 1; MDRin = 1; 
            end
            ST_7: begin
                Write = 1;
            end

            // --- Branching ---
            BR_3: begin
                Gra = 1; Rout_ctrl = 1; CONin = 1; 
            end
            BR_4: begin
                PCout = 1; Yin = 1;
            end
            BR_5: begin
                Cout = 1; ALU_op = ALU_ADD; Zin = 1; // Add offset to PC
                if (CON_out) begin 
                    Zlowout = 1; PCin = 1; 
                end
            end
        endcase
    end
endmodule