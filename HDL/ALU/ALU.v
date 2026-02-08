// ALU.v
module ALU(
    input wire [31:0] A, B,
    input wire [4:0] ALU_op, // Opcode provided by control sequence
    output reg [63:0] C      // 64-bit for MUL/DIV results
);
    wire [31:0] add_sub_res, shift_res;
    wire [63:0] mul_res, div_res;
    wire sub_ctrl;

    // Determine if subtraction is needed for SUB or NEG instructions
    assign sub_ctrl = (ALU_op == 5'b00010 || ALU_op == 5'b01000); 

    // Instantiate sub-modules
    adder add_unit(.A(A), .B(B), .sub_ctrl(sub_ctrl), .Result(add_sub_res));
    Shifter shift_unit(.data_in(B), .shift_count(A[4:0]), .op_sel(ALU_op[2:0]), .data_out(shift_res));
    Division div_unit(.dividend(A), .divisor(B), .result(div_res));
    multiplier mul_unit(.A(A), .B(B), .product(mul_res));

    always @(*) begin
        case(ALU_op)
            5'b00001: C = {32'b0, add_sub_res}; // ADD
            5'b00010: C = {32'b0, add_sub_res}; // SUB
            5'b01000: C = {32'b0, add_sub_res}; // NEG (Implemented as 0 - A)
            5'b00101: C = {32'b0, A & B};       // AND (Built-in allowed)
            5'b00110: C = {32'b0, A | B};       // OR (Built-in allowed)
            5'b00111: C = {32'b0, ~A};          // NOT (Built-in allowed)
            5'b00011: C = div_res;              // DIV (64-bit output)
            5'b01001: C = mul_res;              // MUL (64-bit output)
            5'b00100: C = {32'b0, shift_res};   // SHIFT/ROTATE
            default:  C = 64'b0;
        endcase
    end
endmodule