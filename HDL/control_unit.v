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
    parameter Reset_State = 6'd0, Fetch0 = 6'd1, Fetch1 = 6'd2, Fetch2 = 6'd3, Decode = 6'd35;
    parameter ALU_3 = 6'd4, ALU_4 = 6'd5, ALU_5 = 6'd6; 
    parameter ALUI_3 = 6'd7, ALUI_4 = 6'd8, ALUI_5 = 6'd9; 
    parameter LDI_3 = 6'd10, LDI_4 = 6'd11, LDI_5 = 6'd12;
    parameter LD_3 = 6'd13, LD_4 = 6'd14, LD_5 = 6'd15, LD_6 = 6'd16, LD_7 = 6'd17;
    parameter ST_3 = 6'd18, ST_4 = 6'd19, ST_5 = 6'd20, ST_6 = 6'd21, ST_7 = 6'd22;
    parameter BR_3 = 6'd23, BR_4 = 6'd24, BR_5 = 6'd25, BR_6 = 6'd26;
    parameter MULDIV_3 = 6'd27, MULDIV_4 = 6'd28, MULDIV_5 = 6'd29, MULDIV_6 = 6'd30;
    parameter MF_3 = 6'd31;
    parameter JAL_3 = 6'd32, JAL_4 = 6'd33;
    parameter JR_3 = 6'd34;
    parameter IN_3 = 6'd36, IN_4 = 6'd37;
    parameter OUT_3 = 6'd38;
    parameter HALT_State = 6'd63;

    // --- INSTRUCTION Opcodes (IR[31:27]) ---
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

    // --- ALU Opcodes (From your ALU.v) ---
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

                Fetch2: present_state <= Decode;
                
                Decode: begin
                    case (IR[31:27])
                        INST_ADD, INST_SUB, INST_AND, INST_OR, INST_SHR, INST_SHRA, 
                        INST_SHL, INST_ROR, INST_ROL, INST_NEG, INST_NOT: 
                            present_state <= ALU_3;
                            
                        INST_ADDI, INST_ANDI, INST_ORI: present_state <= ALUI_3;
                        
                        INST_LDI: present_state <= LDI_3;
                        INST_LD: present_state <= LD_3;
                        INST_ST: present_state <= ST_3;
                        
                        INST_MUL, INST_DIV: present_state <= MULDIV_3;
                        
                        INST_MFHI, INST_MFLO: present_state <= MF_3;
                        
                        INST_BRMI, INST_BRPL: present_state <= BR_3;
                        INST_JAL: present_state <= JAL_3;
                        INST_JR: present_state <= JR_3;
                        INST_IN: present_state <= IN_3;
                        INST_OUT: present_state <= OUT_3;
                        
                        INST_NOP: present_state <= Fetch0;
                        INST_HALT: present_state <= HALT_State;
                        default: present_state <= Fetch0; 
                    endcase
                end

                ALU_3: present_state <= ALU_4;
                ALU_4: present_state <= ALU_5;
                ALU_5: present_state <= Fetch0;

                ALUI_3: present_state <= ALUI_4;
                ALUI_4: present_state <= ALUI_5;
                ALUI_5: present_state <= Fetch0;

                LDI_3: present_state <= LDI_4;
                LDI_4: present_state <= LDI_5;
                LDI_5: present_state <= Fetch0;

                LD_3: present_state <= LD_4;
                LD_4: present_state <= LD_5;
                LD_5: present_state <= LD_6;
                LD_6: present_state <= LD_7;
                LD_7: present_state <= Fetch0;
                
                ST_3: present_state <= ST_4;
                ST_4: present_state <= ST_5;
                ST_5: present_state <= ST_6;
                ST_6: present_state <= ST_7;
                ST_7: present_state <= Fetch0;

                MULDIV_3: present_state <= MULDIV_4;
                MULDIV_4: present_state <= MULDIV_5;
                MULDIV_5: present_state <= MULDIV_6;
                MULDIV_6: present_state <= Fetch0;

                MF_3: present_state <= Fetch0;

                JAL_3: present_state <= JAL_4;
                JAL_4: present_state <= Fetch0;
                
                JR_3: present_state <= Fetch0;

                BR_3: present_state <= BR_4;
                BR_4: present_state <= BR_5;
                BR_5: present_state <= BR_6;
                BR_6: present_state <= Fetch0;

                IN_3: present_state <= IN_4;
                IN_4: present_state <= Fetch0;
                OUT_3: present_state <= Fetch0;

                HALT_State: present_state <= HALT_State;
                default: present_state <= Reset_State;
            endcase
        end
    end

    always @(*) begin
        clear = 0; Gra = 0; Grb = 0; Grc = 0; Rin_ctrl = 0; Rout_ctrl = 0; BAout = 0;
        PCin = 0; PCout = 0; IncPC = 0; IRin = 0; Yin = 0; Zin = 0; HIin = 0; LOin = 0; 
        MARin = 0; MDRin = 0; MDRout = 0; Read = 0; Write = 0; Zhighout = 0; Zlowout = 0; 
        HIout = 0; LOout = 0; InPortout = 0; Cout = 0; CONin = 0; OutPortin = 0; InPortin = 0;
        ALU_op = 5'b00000;

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
            Decode: begin
                // Empty state! Signals naturally fall to 0. IR is now locked and stable.
            end

            ALU_3: begin
                Grb = 1; Rout_ctrl = 1; Yin = 1;
            end
            ALU_4: begin
                if (IR[31:27] == INST_NEG || IR[31:27] == INST_NOT) begin
                    Grb = 1; Rout_ctrl = 1; 
                    ALU_op = (IR[31:27] == INST_NEG) ? ALU_NEG : ALU_NOT;
                end else begin
                    Grc = 1; Rout_ctrl = 1; 
                    if (IR[31:27] == INST_ADD) ALU_op = ALU_ADD;
                    else if (IR[31:27] == INST_SUB) ALU_op = ALU_SUB;
                    else if (IR[31:27] == INST_AND) ALU_op = ALU_AND;
                    else if (IR[31:27] == INST_OR) ALU_op = ALU_OR;
                    else if (IR[31:27] == INST_SHR) ALU_op = ALU_SHR;
                    else if (IR[31:27] == INST_SHRA) ALU_op = ALU_SHRA;
                    else if (IR[31:27] == INST_SHL) ALU_op = ALU_SHL;
                    else if (IR[31:27] == INST_ROR) ALU_op = ALU_ROR;
                    else if (IR[31:27] == INST_ROL) ALU_op = ALU_ROL;
                end
                Zin = 1;
            end
            ALU_5: begin
                Zlowout = 1; Gra = 1; Rin_ctrl = 1;
            end

            ALUI_3: begin
                Grb = 1; Rout_ctrl = 1; Yin = 1;
            end
            ALUI_4: begin
                Cout = 1; Zin = 1;
                if (IR[31:27] == INST_ADDI) ALU_op = ALU_ADD;
                else if (IR[31:27] == INST_ANDI) ALU_op = ALU_AND;
                else if (IR[31:27] == INST_ORI) ALU_op = ALU_OR;
            end
            ALUI_5: begin
                Zlowout = 1; Gra = 1; Rin_ctrl = 1;
            end

            MULDIV_3: begin
                Gra = 1; Rout_ctrl = 1; Yin = 1;
            end
            MULDIV_4: begin
                Grb = 1; Rout_ctrl = 1; Zin = 1;
                ALU_op = (IR[31:27] == INST_MUL) ? ALU_MUL : ALU_DIV;
            end
            MULDIV_5: begin
                Zlowout = 1; LOin = 1;
            end
            MULDIV_6: begin
                Zhighout = 1; HIin = 1;
            end

            MF_3: begin
                if (IR[31:27] == INST_MFHI) HIout = 1;
                else LOout = 1;
                Gra = 1; Rin_ctrl = 1;
            end

            LDI_3: begin
                Grb = 1; BAout = 1; Yin = 1; 
            end
            LDI_4: begin
                Cout = 1; ALU_op = ALU_ADD; Zin = 1; 
            end
            LDI_5: begin
                Zlowout = 1; Gra = 1; Rin_ctrl = 1;
            end

            LD_3: begin
                Grb = 1; BAout = 1; Yin = 1;
            end
            LD_4: begin
                Cout = 1; ALU_op = ALU_ADD; Zin = 1; 
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

            ST_3: begin
                Grb = 1; BAout = 1; Yin = 1;
            end
            ST_4: begin
                Cout = 1; ALU_op = ALU_ADD; Zin = 1; 
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

            BR_3: begin
                Gra = 1; Rout_ctrl = 1; CONin = 1; 
            end
            BR_4: begin
                PCout = 1; Yin = 1;
            end
            BR_5: begin
                Cout = 1; ALU_op = ALU_ADD; Zin = 1; 
            end
            BR_6: begin
                if (CON_out) begin 
                    Zlowout = 1; PCin = 1; 
                end
            end

            JAL_3: begin
                PCout = 1; Gra = 1; Rin_ctrl = 1;
            end
            JAL_4: begin
                Grb = 1; Rout_ctrl = 1; PCin = 1;
            end

            JR_3: begin
                Gra = 1; Rout_ctrl = 1; PCin = 1;
            end

            IN_3: begin
                InPortin = 1;
            end
            IN_4: begin
                InPortout = 1; Gra = 1; Rin_ctrl = 1;
            end
            OUT_3: begin
                Gra = 1; Rout_ctrl = 1; OutPortin = 1;
            end
            
            HALT_State: begin
            end
        endcase
    end
endmodule