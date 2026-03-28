module conv2d (
    input  wire        clk,
    input  wire        rst,
    input  wire        enable,
    input  wire signed [7:0] patch    [0:8],
    input  wire signed [7:0] filter_w [0:8],
    input  wire signed [7:0] bias,
    output wire signed [23:0] data_out,
    output reg         valid
);
    // Explicitly signed multiply each of the 9 pairs
    wire signed [23:0] conv_sum;
    assign conv_sum =
        $signed(patch[0]) * $signed(filter_w[0]) +
        $signed(patch[1]) * $signed(filter_w[1]) +
        $signed(patch[2]) * $signed(filter_w[2]) +
        $signed(patch[3]) * $signed(filter_w[3]) +
        $signed(patch[4]) * $signed(filter_w[4]) +
        $signed(patch[5]) * $signed(filter_w[5]) +
        $signed(patch[6]) * $signed(filter_w[6]) +
        $signed(patch[7]) * $signed(filter_w[7]) +
        $signed(patch[8]) * $signed(filter_w[8]) +
        $signed({{16{bias[7]}}, bias});

    // Debug: print intermediate sum
    always @(conv_sum)
        $display("  DEBUG conv_sum = %0d", conv_sum);

    relu relu_inst (
        .data_in  (conv_sum),
        .data_out (data_out)
    );

    always @(posedge clk or posedge rst) begin
        if (rst)         valid <= 1'b0;
        else if (enable) valid <= 1'b1;
        else             valid <= 1'b0;
    end

endmodule