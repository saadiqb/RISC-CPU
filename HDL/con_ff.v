// Phase 2 §2.4 — CON FF for conditional branches (brzr, brnz, brpl, brmi).
// When CONin is asserted, latches whether the branch condition holds, using IR[20:19] as C2
// (Mini SRC: only these two bits of the 4-bit C2 field are used).
// Bus data is R[Ra] while Gra & Rout are asserted (Phase 2 branch control sequence T3).
//
// IR[20:19]: 00 zero, 01 nonzero, 10 positive (non-negative: MSB=0), 11 negative (MSB=1)
module con_ff (
    input wire clock, clear,
    input wire CONin,
    input wire [1:0] cond,
    input wire [31:0] bus_data,
    output reg CON
);
    wire cond_met;
    assign cond_met = (cond == 2'b00) ? (bus_data == 32'b0) :
                      (cond == 2'b01) ? (bus_data != 32'b0) :
                      (cond == 2'b10) ? (~bus_data[31]) :
                      bus_data[31];

    always @(posedge clock) begin
        if (clear)
            CON <= 1'b0;
        else if (CONin)
            CON <= cond_met;
    end
endmodule
