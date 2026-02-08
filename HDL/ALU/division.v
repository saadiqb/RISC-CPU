module Division(
    input wire [31:0] dividend,
    input wire [31:0] divisor,
    output wire [63:0] result // [63:32] Remainder, [31:0] Quotient
);
    reg [31:0] Q;
    reg [31:0] M;
    reg [31:0] A;
    integer i;

    always @(*) begin
        Q = dividend;
        M = divisor;
        A = 32'b0;

        if (M == 0) begin
            A = 32'hFFFFFFFF; // Error handling for Div by Zero
            Q = 32'hFFFFFFFF;
        end else begin
            for (i = 0; i < 32; i = i + 1) begin
                {A, Q} = {A, Q} << 1; // Left shift A and Q [cite: 16]
                A = A - M;
                if (A[31] == 1'b1) begin // If A < 0
                    Q[0] = 1'b0;
                    A = A + M; // Restore A
                end else begin
                    Q[0] = 1'b1;
                end
            end
        end
    end
    assign result = {A, Q}; // 
endmodule