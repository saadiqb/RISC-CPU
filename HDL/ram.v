module ram (
    input wire clk,
    input wire read,
    input wire write,
    input wire [8:0] address,
    input wire [31:0] data_in,
    output reg [31:0] data_out
);
    // 512 x 32-bit memory array
    reg [31:0] memory [0:511]; 

    integer i; 

    // Initialize all memory to 0 to avoid undefined 'x' states in simulation
    initial begin
        for (i = 0; i < 512; i = i + 1) begin
            memory[i] = 32'b0;
        end
    end

    // Synchronous Read and Write
    always @(posedge clk) begin
        // Write operation
        if (write) begin
            memory[address] <= data_in;
        end
        // Read operation
        if (read) begin
            data_out <= memory[address];
        end
    end
endmodule