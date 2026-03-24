module ram (
    input wire clk,
    input wire read,
    input wire write,
    input wire [8:0] address,
    input wire [31:0] data_in,
    output wire [31:0] data_out
);
    // 512 x 32-bit memory array
    reg [31:0] memory [0:511]; 

    integer i;
    initial begin
        for (i = 0; i < 512; i = i + 1) begin
            memory[i] = 32'b0;
        end
    end

    // Synchronous Write
    always @(posedge clk) begin
        if (write) begin
            memory[address] <= data_in;
        end
    end

    // Asynchronous Read
    assign data_out = read ? memory[address] : 32'b0;

endmodule