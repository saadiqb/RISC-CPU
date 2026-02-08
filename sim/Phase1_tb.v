T3: begin // Step T3 for Multiply: R3out, Yin [cite: 596]
    R3out <= 1; Yin <= 1;
    #20 R3out <= 0; Yin <= 0;
end
T4: begin // Step T4: R1out, MUL, Zin [cite: 596]
    R1out <= 1; ALU_op <= 5'b01001; Zin <= 1;
    #20 R1out <= 0; Zin <= 0;
end
T5: begin // Step T5: Zlowout, LOin [cite: 596]
    Zlowout <= 1; LOin <= 1;
    #20 Zlowout <= 0; LOin <= 0;
end
T6: begin // Step T6: Zhighout, HIin [cite: 596]
    Zhighout <= 1; HIin <= 1;
    #20 Zhighout <= 0; HIin <= 0;
end