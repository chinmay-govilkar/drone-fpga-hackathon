module conv2d_tb;
    reg        clk, rst, enable;
    reg signed [7:0] patch    [0:8];
    reg signed [7:0] filter_w [0:8];
    reg signed [7:0] bias;
    wire signed [23:0] data_out;
    wire valid;

    conv2d uut (
        .clk(clk), .rst(rst), .enable(enable),
        .patch(patch), .filter_w(filter_w),
        .bias(bias), .data_out(data_out), .valid(valid)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst = 1; enable = 0;
        #20 rst = 0;

        // Test 1: all 1s — expect 9
        patch[0]=1; patch[1]=1; patch[2]=1;
        patch[3]=1; patch[4]=1; patch[5]=1;
        patch[6]=1; patch[7]=1; patch[8]=1;
        filter_w[0]=1; filter_w[1]=1; filter_w[2]=1;
        filter_w[3]=1; filter_w[4]=1; filter_w[5]=1;
        filter_w[6]=1; filter_w[7]=1; filter_w[8]=1;
        bias = 0; enable = 1; #10;
        $display("Test 1 - all 1s: out = %0d (expect 9)", data_out);

        // Test 2: center=5, bias=2 — expect 15
        patch[0]=1; patch[1]=1; patch[2]=1;
        patch[3]=1; patch[4]=5; patch[5]=1;
        patch[6]=1; patch[7]=1; patch[8]=1;
        filter_w[0]=1; filter_w[1]=1; filter_w[2]=1;
        filter_w[3]=1; filter_w[4]=1; filter_w[5]=1;
        filter_w[6]=1; filter_w[7]=1; filter_w[8]=1;
        bias = 2; #10;
        $display("Test 2 - center=5,bias=2: out = %0d (expect 15)", data_out);

        // Test 3: filter all -1, patch all 1s — expect 0
        patch[0]=1; patch[1]=1; patch[2]=1;
        patch[3]=1; patch[4]=1; patch[5]=1;
        patch[6]=1; patch[7]=1; patch[8]=1;
        filter_w[0]=-1; filter_w[1]=-1; filter_w[2]=-1;
        filter_w[3]=-1; filter_w[4]=-1; filter_w[5]=-1;
        filter_w[6]=-1; filter_w[7]=-1; filter_w[8]=-1;
        bias = 0; #10;
        $display("Test 3 - negative ReLU: out = %0d (expect 0)", data_out);

        $finish;
    end
endmodule