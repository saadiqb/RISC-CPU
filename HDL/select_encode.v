// Select and Encode (Phase 2 §2.2) + R0 bus gating flag for §2.3.
// Ra = IR[26:23], Rb = IR[22:19], Rc = IR[18:15] (Mini SRC instruction formats).
// R0_bus_zero: asserted when the selected field is R0, BAout is on, and Rout is off — drive 0 on
// the bus for ld/ldi/st base address (R0 + C with R0 as “no register”); if Rout is also on, real R0.
module select_encode (
    input wire [31:0] IR,
    input wire Gra, Grb, Grc,
    input wire Rin, Rout, BAout,
    output wire [15:0] R_in,
    output wire [15:0] R_out,
    output wire [31:0] C_sign_extended,
    output wire R0_bus_zero
);
    wire sel = Gra | Grb | Grc;
    wire [3:0] reg_field = Gra ? IR[26:23] : (Grb ? IR[22:19] : IR[18:15]);

    assign R0_bus_zero = sel & (reg_field == 4'd0) & BAout & ~Rout;

    // Sign-extend IR[18:0] using IR[18] as MSB (Phase 2 Figure 4)
    assign C_sign_extended = {{13{IR[18]}}, IR[18:0]};

    genvar k;
    generate
        for (k = 0; k < 16; k = k + 1) begin : g_dec
            assign R_in[k]  = Rin & sel & (reg_field == k);
            // Grb without Rout still drives Rb≠R0 onto bus (Phase 2 ld/ldi/st T3: Grb, BAout, Yin).
            // R0 uses BAout|Rout with §2.3 zeroing when BAout & ~Rout.
            assign R_out[k] = sel & (reg_field == k) &
                ((k == 0) ? (Rout | BAout) : (Rout | Grb));
        end
    endgenerate
endmodule
