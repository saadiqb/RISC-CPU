// 512 x 32 RAM for Mini SRC memory subsystem
// Write is synchronous; read is combinational so MAR+Read+MDRin in one cycle
// matches the Phase 2 control sequences (instruction and data fetch).
module ram (
    input wire clk,
    input wire read,
    input wire write,
    input wire [8:0] address,
    input wire [31:0] data_in,
    output wire [31:0] data_out
);
    reg [31:0] mem_array [0:511];

    // Zero init for simulation; optional hex load per lab handout ($readmemh).
    initial begin
        integer i;
        for (i = 0; i < 512; i = i + 1)
            mem_array[i] = 32'b0;
    end

    always @(posedge clk) begin
        if (write)
            mem_array[address] <= data_in;
    end

    assign data_out = read ? mem_array[address] : 32'd0;
endmodule
