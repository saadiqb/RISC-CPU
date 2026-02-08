// adder.v - handles subtraction as well
module adder(
    input [31:0] A, B,
    input sub_ctrl,          // High for Subtraction
    output [31:0] Result
);
    wire [31:0] B_complement;
    reg [32:0] carry;
    integer i;

    // Use bitwise XOR for 2's complement inversion if sub_ctrl is high
    assign B_complement = (sub_ctrl) ? ~B : B;

    always @(*) begin
        // Carry-in is 1 for subtraction to complete the +1 for 2's complement
        carry[0] = sub_ctrl; 
        for (i = 0; i < 32; i = i + 1) begin
            // Manual logic for Full Adder: Sum = A ^ B ^ Cin
            Result[i] = A[i] ^ B_complement[i] ^ carry[i];
            // Manual logic for Carry Out: Cout = (A & B) | (Cin & (A ^ B))
            carry[i+1] = (A[i] & B_complement[i]) | (carry[i] & (A[i] | B_complement[i]));
        end
    end
endmodule