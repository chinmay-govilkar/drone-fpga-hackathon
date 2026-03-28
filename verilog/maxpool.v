// MaxPooling2D — 2x2 pool, stride 2
// Takes 4 values from a 2x2 window, outputs the largest one
// No weights needed — pure comparison logic

module maxpool (
    input  wire signed [23:0] in00, in01,
                               in10, in11,
    output wire signed [23:0] max_out
);
    wire signed [23:0] max_top, max_bot;

    // Compare top row
    assign max_top = (in00 > in01) ? in00 : in01;
    // Compare bottom row
    assign max_bot = (in10 > in11) ? in10 : in11;
    // Compare winners
    assign max_out = (max_top > max_bot) ? max_top : max_bot;

endmodule