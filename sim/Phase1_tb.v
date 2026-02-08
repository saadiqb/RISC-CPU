`timescale 1ns/10ps

module Phase1_tb;
    reg clock, clear;
    reg R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in;
    reg R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in;
    reg R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out;
    reg R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out;
    reg PCin, PCout, IRin, Yin, Zin, HIin, LOin, MARin, MDRin, MDRout, Read;
    reg Zhighout, Zlowout, HIout, LOout, InPortout, Cout;
    reg [4:0] ALU_op;
    reg [31:0] Mdatain;
    wire [31:0] BusMuxOut_out;

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

    DataPath DUT(
        .clock(clock), .clear(clear),
        .R0in(R0in), .R1in(R1in), .R2in(R2in), .R3in(R3in), .R4in(R4in), .R5in(R5in), .R6in(R6in), .R7in(R7in),
        .R8in(R8in), .R9in(R9in), .R10in(R10in), .R11in(R11in), .R12in(R12in), .R13in(R13in), .R14in(R14in), .R15in(R15in),
        .R0out(R0out), .R1out(R1out), .R2out(R2out), .R3out(R3out), .R4out(R4out), .R5out(R5out), .R6out(R6out), .R7out(R7out),
        .R8out(R8out), .R9out(R9out), .R10out(R10out), .R11out(R11out), .R12out(R12out), .R13out(R13out), .R14out(R14out), .R15out(R15out),
        .PCin(PCin), .PCout(PCout), .IRin(IRin), .Yin(Yin), .Zin(Zin), .HIin(HIin), .LOin(LOin), .MARin(MARin), .MDRin(MDRin), .MDRout(MDRout), .Read(Read),
        .Zhighout(Zhighout), .Zlowout(Zlowout), .HIout(HIout), .LOout(LOout), .InPortout(InPortout), .Cout(Cout),
        .ALU_op(ALU_op),
        .Mdatain(Mdatain),
        .BusMuxOut_out(BusMuxOut_out)
    );

    always #10 clock = ~clock;

    task clear_controls;
        begin
            R0in = 0; R1in = 0; R2in = 0; R3in = 0; R4in = 0; R5in = 0; R6in = 0; R7in = 0;
            R8in = 0; R9in = 0; R10in = 0; R11in = 0; R12in = 0; R13in = 0; R14in = 0; R15in = 0;
            R0out = 0; R1out = 0; R2out = 0; R3out = 0; R4out = 0; R5out = 0; R6out = 0; R7out = 0;
            R8out = 0; R9out = 0; R10out = 0; R11out = 0; R12out = 0; R13out = 0; R14out = 0; R15out = 0;
            PCin = 0; PCout = 0; IRin = 0; Yin = 0; Zin = 0; HIin = 0; LOin = 0; MARin = 0; MDRin = 0; MDRout = 0; Read = 0;
            Zhighout = 0; Zlowout = 0; HIout = 0; LOout = 0; InPortout = 0; Cout = 0;
            ALU_op = ALU_ADD;
        end
    endtask

    task set_Rin;
        input integer idx;
        input reg val;
        begin
            case (idx)
                0: R0in = val;  1: R1in = val;  2: R2in = val;  3: R3in = val;
                4: R4in = val;  5: R5in = val;  6: R6in = val;  7: R7in = val;
                8: R8in = val;  9: R9in = val; 10: R10in = val; 11: R11in = val;
               12: R12in = val; 13: R13in = val; 14: R14in = val; 15: R15in = val;
                default: ;
            endcase
        end
    endtask

    task set_Rout;
        input integer idx;
        input reg val;
        begin
            case (idx)
                0: R0out = val;  1: R1out = val;  2: R2out = val;  3: R3out = val;
                4: R4out = val;  5: R5out = val;  6: R6out = val;  7: R7out = val;
                8: R8out = val;  9: R9out = val; 10: R10out = val; 11: R11out = val;
               12: R12out = val; 13: R13out = val; 14: R14out = val; 15: R15out = val;
                default: ;
            endcase
        end
    endtask

    task load_reg;
        input integer idx;
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
            set_Rin(idx, 1);
            @(posedge clock);
            #1;
            clear_controls();
            Mdatain = 32'b0;
        end
    endtask

    task check_reg;
        input integer idx;
        input [31:0] expected;
        input [127:0] label;
        begin
            @(negedge clock);
            clear_controls();
            case (idx)
                16: HIout = 1;
                17: LOout = 1;
                default: set_Rout(idx, 1);
            endcase
            #1;
            if (BusMuxOut_out !== expected) begin
                $display("FAIL %s: expected %h got %h", label, expected, BusMuxOut_out);
                errors = errors + 1;
            end else begin
                $display("PASS %s: %h", label, BusMuxOut_out);
            end
            clear_controls();
        end
    endtask

    task exec_bin_op;
        input integer dst;
        input integer srcA;
        input integer srcB;
        input [4:0] op;
        input [31:0] expected;
        input [127:0] label;
        begin
            @(negedge clock);
            clear_controls();
            set_Rout(srcA, 1); Yin = 1;
            @(posedge clock);
            #1;
            clear_controls();
            @(negedge clock);
            set_Rout(srcB, 1); ALU_op = op; Zin = 1;
            @(posedge clock);
            #1;
            clear_controls();
            @(negedge clock);
            Zlowout = 1; set_Rin(dst, 1);
            @(posedge clock);
            #1;
            clear_controls();
            check_reg(dst, expected, label);
        end
    endtask

    task exec_unary_op;
        input integer dst;
        input integer src;
        input [4:0] op;
        input [31:0] expected;
        input [127:0] label;
        begin
            @(negedge clock);
            clear_controls();
            set_Rout(src, 1); ALU_op = op; Zin = 1;
            @(posedge clock);
            #1;
            clear_controls();
            @(negedge clock);
            Zlowout = 1; set_Rin(dst, 1);
            @(posedge clock);
            #1;
            clear_controls();
            check_reg(dst, expected, label);
        end
    endtask

    task exec_shift_op;
        input integer dst;
        input integer src;
        input integer count_reg;
        input [4:0] op;
        input [31:0] expected;
        input [127:0] label;
        begin
            @(negedge clock);
            clear_controls();
            set_Rout(src, 1); Yin = 1;
            @(posedge clock);
            #1;
            clear_controls();
            @(negedge clock);
            set_Rout(count_reg, 1); ALU_op = op; Zin = 1;
            @(posedge clock);
            #1;
            clear_controls();
            @(negedge clock);
            Zlowout = 1; set_Rin(dst, 1);
            @(posedge clock);
            #1;
            clear_controls();
            check_reg(dst, expected, label);
        end
    endtask

    task exec_mul;
        input integer srcA;
        input integer srcB;
        input [31:0] exp_lo;
        input [31:0] exp_hi;
        input [127:0] label;
        begin
            @(negedge clock);
            clear_controls();
            set_Rout(srcA, 1); Yin = 1;
            @(posedge clock);
            #1;
            clear_controls();
            @(negedge clock);
            set_Rout(srcB, 1); ALU_op = ALU_MUL; Zin = 1;
            @(posedge clock);
            #1;
            clear_controls();
            @(negedge clock);
            Zlowout = 1; LOin = 1;
            @(posedge clock);
            #1;
            clear_controls();
            @(negedge clock);
            Zhighout = 1; HIin = 1;
            @(posedge clock);
            #1;
            clear_controls();
            check_reg(17, exp_lo, {label, " LO"});
            check_reg(16, exp_hi, {label, " HI"});
        end
    endtask

    task exec_div;
        input integer srcA;
        input integer srcB;
        input [31:0] exp_quo;
        input [31:0] exp_rem;
        input [127:0] label;
        begin
            @(negedge clock);
            clear_controls();
            set_Rout(srcA, 1); Yin = 1;
            @(posedge clock);
            #1;
            clear_controls();
            @(negedge clock);
            set_Rout(srcB, 1); ALU_op = ALU_DIV; Zin = 1;
            @(posedge clock);
            #1;
            clear_controls();
            @(negedge clock);
            Zlowout = 1; LOin = 1;
            @(posedge clock);
            #1;
            clear_controls();
            @(negedge clock);
            Zhighout = 1; HIin = 1;
            @(posedge clock);
            #1;
            clear_controls();
            check_reg(17, exp_quo, {label, " LO"});
            check_reg(16, exp_rem, {label, " HI"});
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

        // AND, OR
        load_reg(5, 32'h00000034);
        load_reg(6, 32'h00000045);
        exec_bin_op(2, 5, 6, ALU_AND, 32'h00000004, "AND");
        exec_bin_op(3, 5, 6, ALU_OR,  32'h00000075, "OR");

        // ADD, SUB
        load_reg(8, 32'h00000010);
        load_reg(9, 32'h00000005);
        exec_bin_op(10, 8, 9, ALU_ADD, 32'h00000015, "ADD");
        exec_bin_op(11, 8, 9, ALU_SUB, 32'h0000000B, "SUB");

        // MUL
        load_reg(3, 32'h00000007);
        load_reg(1, 32'h00000003);
        exec_mul(3, 1, 32'h00000015, 32'h00000000, "MUL");

        // DIV
        load_reg(3, 32'h00000014);
        load_reg(1, 32'h00000003);
        exec_div(3, 1, 32'h00000006, 32'h00000002, "DIV");

        // NEG, NOT
        load_reg(7, 32'h00000009);
        exec_unary_op(12, 7, ALU_NEG, 32'hFFFFFFF7, "NEG");
        load_reg(7, 32'h0000000F);
        exec_unary_op(13, 7, ALU_NOT, 32'hFFFFFFF0, "NOT");

        // SHR
        load_reg(0, 32'h00000010);
        load_reg(4, 32'h00000002);
        exec_shift_op(14, 0, 4, ALU_SHR, 32'h00000004, "SHR");

        // SHRA
        load_reg(0, 32'h80000000);
        load_reg(4, 32'h00000001);
        exec_shift_op(15, 0, 4, ALU_SHRA, 32'hC0000000, "SHRA");

        // SHL
        load_reg(0, 32'h00000001);
        load_reg(4, 32'h00000003);
        exec_shift_op(2, 0, 4, ALU_SHL, 32'h00000008, "SHL");

        // ROR
        load_reg(0, 32'h80000001);
        load_reg(4, 32'h00000001);
        exec_shift_op(3, 0, 4, ALU_ROR, 32'hC0000000, "ROR");

        // ROL
        load_reg(0, 32'h80000001);
        load_reg(4, 32'h00000001);
        exec_shift_op(5, 0, 4, ALU_ROL, 32'h00000003, "ROL");

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTS FAILED: %0d errors", errors);

        $finish;
    end
endmodule