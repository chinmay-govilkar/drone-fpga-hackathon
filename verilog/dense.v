// Dense (Fully Connected) layer
// Computes: output = ReLU(sum(input[i] * weight[i]) + bias)
// Used twice: 1024->32 and 32->1

module dense #(
    parameter N = 32    // number of inputs — override for each layer
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        enable,
    input  wire signed [23:0] data_in  [0:N-1],
    input  wire signed [7:0]  weights  [0:N-1],
    input  wire signed [7:0]  bias,
    input  wire        apply_relu,       // 1 for hidden layer, 0 for output
    output reg  signed [23:0] data_out,
    output reg         valid
);
    integer k;
    reg signed [23:0] acc;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out <= 0;
            valid    <= 0;
            acc      <= 0;
        end
        else if (enable) begin
            acc = {{16{bias[7]}}, bias};     // start with bias
            for (k = 0; k < N; k = k + 1)
                acc = acc + $signed(data_in[k]) * $signed(weights[k]);

            // Apply ReLU only for hidden layers
            if (apply_relu)
                data_out <= (acc[23]) ? 24'sd0 : acc;
            else
                data_out <= acc;

            valid <= 1;
        end
        else valid <= 0;
    end

endmodule