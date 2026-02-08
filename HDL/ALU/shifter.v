module Shifter(
    input wire [31:0] data_in,
    input wire [4:0] shift_count,
    input wire [2:0] op_sel, // 0:SHR, 1:SHRA, 2:SHL, 3:ROR, 4:ROL
    output reg [31:0] data_out
);
    always @(*) begin
        case(op_sel)
            3'b000: data_out = data_in >> shift_count;               // SHR [cite: 559]
            3'b001: data_out = $signed(data_in) >>> shift_count;    // SHRA [cite: 561]
            3'b010: data_out = data_in << shift_count;               // SHL [cite: 564]
            3'b011: data_out = (data_in >> shift_count) | (data_in << (32 - shift_count)); // ROR [cite: 568]
            3'b100: data_out = (data_in << shift_count) | (data_in >> (32 - shift_count)); // ROL [cite: 570]
            default: data_out = 32'h0;
        endcase
    end
endmodule