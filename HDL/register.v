module register #(parameter DATA_WIDTH = 32)(
    input wire clear, clock, enable, 
    input wire [DATA_WIDTH-1:0] BusMuxOut,
    output wire [DATA_WIDTH-1:0] BusMuxIn
);
    reg [DATA_WIDTH-1:0] q;
    always @ (posedge clock) begin 
        if (clear) q <= {DATA_WIDTH{1'b0}};
        else if (enable) q <= BusMuxOut;
    end
    assign BusMuxIn = q;
endmodule