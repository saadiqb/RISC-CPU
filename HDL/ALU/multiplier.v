module Multiplier(
    input wire [31:0] multiplicand,
    input wire [31:0] multiplier,
    output wire [63:0] result
);
    function automatic signed [63:0] booth_mul_radix4;
        input signed [31:0] mcand;
        input signed [31:0] mplier;
        integer i;
        reg signed [63:0] acc;
        reg signed [63:0] m_ext;
        reg signed [63:0] pp;
        reg [32:0] q_ext;
        reg [2:0] bits;
        begin
            acc = 64'sd0;
            m_ext = {{32{mcand[31]}}, mcand};
            q_ext = {mplier, 1'b0};
            for (i = 0; i < 16; i = i + 1) begin
                bits = {q_ext[2*i+2], q_ext[2*i+1], q_ext[2*i]};
                case (bits)
                    3'b000, 3'b111: pp = 64'sd0;
                    3'b001, 3'b010: pp = m_ext;
                    3'b011:         pp = m_ext <<< 1;
                    3'b100:         pp = -(m_ext <<< 1);
                    3'b101, 3'b110: pp = -m_ext;
                    default:        pp = 64'sd0;
                endcase
                acc = acc + (pp <<< (2*i));
            end
            booth_mul_radix4 = acc;
        end
    endfunction

    assign result = booth_mul_radix4(multiplicand, multiplier);
endmodule
