module dense_tb;
    parameter N = 4;    // small size for testing

    reg        clk, rst, enable, apply_relu;
    reg signed [23:0] data_in  [0:N-1];
    reg signed [7:0]  weights  [0:N-1];
    reg signed [7:0]  bias;
    wire signed [23:0] data_out;
    wire valid;

    dense #(.N(N)) uut (
        .clk(clk), .rst(rst), .enable(enable),
        .data_in(data_in), .weights(weights),
        .bias(bias), .apply_relu(apply_relu),
        .data_out(data_out), .valid(valid)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst = 1; enable = 0; apply_relu = 1;
        #20 rst = 0;

        // Test 1: [1,2,3,4] dot [1,1,1,1] + bias=0 = 10
        data_in[0]=1; data_in[1]=2; data_in[2]=3; data_in[3]=4;
        weights[0]=1; weights[1]=1; weights[2]=1; weights[3]=1;
        bias = 0; enable = 1; #10;
        $display("Test 1 - dot product: out=%0d (expect 10)", data_out);

        // Test 2: same but bias=5 → 15
        bias = 5; #10;
        $display("Test 2 - with bias=5: out=%0d (expect 15)", data_out);

        // Test 3: negative weights → relu clips to 0
        weights[0]=-1; weights[1]=-1; weights[2]=-1; weights[3]=-1;
        bias = 0; apply_relu = 1; #10;
        $display("Test 3 - negative relu: out=%0d (expect 0)", data_out);

        // Test 4: no relu (output layer) → negative passes through
        apply_relu = 0; #10;
        $display("Test 4 - no relu: out=%0d (expect -10)", data_out);

        $finish;
    end
endmodule