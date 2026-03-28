// ReLU activation — simplest module in the whole CNN
// If input is negative → output 0
// If input is positive → output as-is
module relu (
    input  wire signed [23:0] data_in,
    output wire signed [23:0] data_out
);
    assign data_out = (data_in[23]) ? 24'sd0 : data_in;
    // data_in[23] is the sign bit — if 1, number is negative

endmodule