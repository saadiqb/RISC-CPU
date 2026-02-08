// ALU.v
module ALU(
    input wire [31:0] A, B,
    input wire [4:0] ALU_op, // Opcode provided by control sequence
    output reg [63:0] C      // 64-bit for MUL/DIV results
);
    wire [31:0] add_sub_res, shift_res;
    wire [63:0] mul_res, div_res;
    wire sub_ctrl;
    wire [31:0] add_A, add_B;
    wire [2:0] shift_sel;

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

    // Determine if subtraction is needed for SUB or NEG instructions
    assign sub_ctrl = (ALU_op == ALU_SUB || ALU_op == ALU_NEG);
    assign add_A = (ALU_op == ALU_NEG) ? 32'b0 : A;
    assign add_B = B;
    assign shift_sel = (ALU_op == ALU_SHR)  ? 3'b000 :
                       (ALU_op == ALU_SHRA) ? 3'b001 :
                       (ALU_op == ALU_SHL)  ? 3'b010 :
                       (ALU_op == ALU_ROR)  ? 3'b011 :
                       (ALU_op == ALU_ROL)  ? 3'b100 : 3'b000;

    // Instantiate sub-modules
    adder add_unit(.A(add_A), .B(add_B), .sub_ctrl(sub_ctrl), .Result(add_sub_res));
    Shifter shift_unit(.data_in(A), .shift_count(B[4:0]), .op_sel(shift_sel), .data_out(shift_res));
    Division div_unit(.dividend(A), .divisor(B), .result(div_res));
    Multiplier mul_unit(.multiplicand(A), .multiplier(B), .result(mul_res));

    always @(*) begin
        case(ALU_op)
            ALU_ADD:  C = {32'b0, add_sub_res};
            ALU_SUB:  C = {32'b0, add_sub_res};
            ALU_NEG:  C = {32'b0, add_sub_res};
            ALU_AND:  C = {32'b0, A & B};
            ALU_OR:   C = {32'b0, A | B};
            ALU_NOT:  C = {32'b0, ~B};
            ALU_DIV:  C = div_res;
            ALU_MUL:  C = mul_res;
            ALU_SHR,
            ALU_SHRA,
            ALU_SHL,
            ALU_ROR,
            ALU_ROL:  C = {32'b0, shift_res};
            default:  C = 64'b0;
        endcase
    end
endmodule