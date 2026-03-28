module maxpool_tb;
    reg signed [23:0] in00, in01, in10, in11;
    wire signed [23:0] max_out;

    maxpool uut (
        .in00(in00), .in01(in01),
        .in10(in10), .in11(in11),
        .max_out(max_out)
    );

    initial begin
        // Test 1: max is top-left
        in00=9; in01=3; in10=2; in11=1; #10;
        $display("Test 1 - max of 9,3,2,1: out=%0d (expect 9)", max_out);

        // Test 2: max is bottom-right
        in00=1; in01=2; in10=3; in11=15; #10;
        $display("Test 2 - max of 1,2,3,15: out=%0d (expect 15)", max_out);

        // Test 3: all equal
        in00=7; in01=7; in10=7; in11=7; #10;
        $display("Test 3 - all equal 7: out=%0d (expect 7)", max_out);

        // Test 4: including zero (ReLU output is always >=0)
        in00=0; in01=0; in10=0; in11=5; #10;
        $display("Test 4 - one non-zero: out=%0d (expect 5)", max_out);

        $finish;
    end
endmodule