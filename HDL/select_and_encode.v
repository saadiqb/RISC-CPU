module select_and_encode (
    input wire [31:0] IR,    
    input wire Gra,       
    input wire Grb,          
    input wire Grc,          
    input wire Rin,       
    input wire Rout,        
    input wire BAout,         
    input wire Cout,
    input wire R12in_force,

    output wire [15:0] Rin_bus, 
    output wire [15:0] Rout_bus, 
    output wire [31:0] C_bus   
);

    // 1. Extract the 4-bit register fields from the Instruction Register (IR)
    wire [3:0] Ra = IR[26:23];
    wire [3:0] Rb = IR[22:19];
    wire [3:0] Rc = IR[18:15];

    // 2. Extract the 19-bit immediate field
    wire [18:0] imm19 = IR[18:0];

    // 3. Gate each register field using the Gr control signals
    wire [3:0] Ra_gated = Gra ? Ra : 4'b0000;
    wire [3:0] Rb_gated = Grb ? Rb : 4'b0000;
    wire [3:0] Rc_gated = Grc ? Rc : 4'b0000;

    wire [3:0] reg_select = Ra_gated | Rb_gated | Rc_gated;

    // 4. Implement a 4-to-16 decoder
    reg [15:0] decoder_out;
    always @(*) begin
        decoder_out = 16'b0;
        decoder_out[reg_select] = 1'b1; // Set the specific bit for the chosen register
    end

    // 5. Generate Enable Signals
    wire write_enable = Rin;
    // Rout enables a standard register read. BAout enables reading a base register for address math.
    wire read_enable  = Rout | BAout; 

    // Generate the final one-hot output buses
    assign Rin_bus  = write_enable
        ? (R12in_force ? 16'b0001_0000_0000_0000 : decoder_out)
        : 16'b0;
    assign Rout_bus = read_enable  ? decoder_out : 16'b0;

    // 6. Sign extension logic (19-bit to 32-bit)
    // Replicates the 18th bit (the sign bit) 13 times and concatenates the rest
    wire [31:0] sign_ext_imm = {{13{imm19[18]}}, imm19};

    // Output the sign-extended constant only when Cout is high
    assign C_bus = Cout ? sign_ext_imm : 32'b0;

endmodule