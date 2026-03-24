// MAC Unit — Multiply Accumulate
// Computes: acc = acc + (input * weight)
// This is the core building block of every CNN layer

module mac_unit (
    input  wire        clk,
    input  wire        rst,
    input  wire        enable,
    input  wire signed [7:0]  data_in,    // 8-bit input pixel
    input  wire signed [7:0]  weight,     // 8-bit quantized weight
    output reg  signed [23:0] acc_out,    // 24-bit accumulator (prevents overflow)
    output reg         valid              // goes high when result is ready
);

    // Intermediate product is 16-bit (8x8 = 16 bits needed)
    wire signed [15:0] product;
    assign product = data_in * weight;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            acc_out <= 24'sd0;
            valid   <= 1'b0;
        end
        else if (enable) begin
            acc_out <= acc_out + {{8{product[15]}}, product}; // sign extend to 24 bits
            valid   <= 1'b1;
        end
        else begin
            valid   <= 1'b0;
        end
    end

endmodule