module relu_tb;
    reg  signed [23:0] data_in;
    wire signed [23:0] data_out;

    relu uut (.data_in(data_in), .data_out(data_out));

    initial begin
        // Test positive number — should pass through
        data_in = 24'sd15;  #10;
        $display("Test 1 — relu(15)  = %0d (expect 15)", data_out);

        // Test negative number — should become 0
        data_in = -24'sd6;  #10;
        $display("Test 2 — relu(-6)  = %0d (expect 0)",  data_out);

        // Test zero — should stay 0
        data_in = 24'sd0;   #10;
        $display("Test 3 — relu(0)   = %0d (expect 0)",  data_out);

        // Test large value
        data_in = 24'sd1000; #10;
        $display("Test 4 — relu(1000)= %0d (expect 1000)", data_out);

        $finish;
    end
endmodule