module con_ff (
    input wire clear,
    input wire clock,
    input wire CONin,
    input wire [1:0] IR_C2,      // IR[20:19] - The C2 field
    input wire [31:0] BusMuxOut, // The bus value being evaluated
    output reg CON               // Output flag to Control Unit
);
    // Condition checks based on Figure 7
    wire eq0  = (BusMuxOut == 32'b0); // = 0
    wire neq0 = !eq0;                 // != 0
    wire geq0 = !BusMuxOut[31];       // >= 0 (Sign bit is 0)
    wire lt0  = BusMuxOut[31];        // < 0  (Sign bit is 1)

    reg d_in;

    // Decoder for IR<20..19>
    always @(*) begin
        case (IR_C2)
            2'b00: d_in = eq0;  // brzr
            2'b01: d_in = neq0; // brnz
            2'b10: d_in = geq0; // brpl
            2'b11: d_in = lt0;  // brmi
            default: d_in = 1'b0;
        endcase
    end

    // D Flip-Flop
    always @(posedge clock) begin
        if (clear) 
            CON <= 1'b0;
        else if (CONin) 
            CON <= d_in;
    end
endmodule