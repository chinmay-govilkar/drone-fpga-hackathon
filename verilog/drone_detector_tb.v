module drone_detector_tb;
    reg        clk, rst, enable;
    reg signed [7:0] spectrogram [0:1023];
    wire       drone_detected;
    wire       valid;

    drone_detector uut (
        .clk(clk), .rst(rst), .enable(enable),
        .spectrogram(spectrogram),
        .drone_detected(drone_detected),
        .valid(valid)
    );

    integer i;
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("drone_detector.vcd");
        $dumpvars(0, drone_detector_tb);

        rst = 1; enable = 0;
        #20 rst = 0;

        // Test 1: all zeros input (silence) → expect not drone
        for (i = 0; i < 1024; i = i + 1)
            spectrogram[i] = 0;
        enable = 1; #200;
        $display("Test 1 - silence: drone=%0d (expect 0)", drone_detected);

        // Test 2: all max value (loud noise) → could be drone
        rst = 1; #10; rst = 0;
        for (i = 0; i < 1024; i = i + 1)
            spectrogram[i] = 127;
        enable = 1; #200;
        $display("Test 2 - loud input: drone=%0d", drone_detected);

        $display("Top-level simulation complete!");
        $finish;
    end
endmodule