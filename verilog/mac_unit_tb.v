// Testbench for mac_unit
// Run this to verify your MAC works correctly

module mac_unit_tb;

    reg        clk, rst, enable;
    reg  signed [7:0] data_in, weight;
    wire signed [23:0] acc_out;
    wire valid;

    // Instantiate the MAC unit
    mac_unit uut (
        .clk(clk), .rst(rst), .enable(enable),
        .data_in(data_in), .weight(weight),
        .acc_out(acc_out), .valid(valid)
    );

    // Clock: toggles every 5ns = 100MHz
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("mac_unit.vcd");
        $dumpvars(0, mac_unit_tb);

        // Reset
        rst = 1; enable = 0; data_in = 0; weight = 0;
        #20 rst = 0;

        // Test 1: 3 * 5 = 15
        enable = 1; data_in = 8'sd3; weight = 8'sd5;
        #10;
        $display("Test 1 — 3*5: acc = %0d (expect 15)", acc_out);

        // Test 2: accumulate 2 * 4 = 8, total = 23
        data_in = 8'sd2; weight = 8'sd4;
        #10;
        $display("Test 2 — +2*4: acc = %0d (expect 23)", acc_out);

// Test 3: negative weight -3 * 2 = -6, total = 17
data_in = 8'sd2; weight = -8'sd3;
#10;
$display("Test 3 — +2*(-3): acc = %0d (expect 17)", acc_out);

// Test 4: reset clears accumulator
rst = 1; #10; rst = 0;
$display("Test 4 — after reset: acc = %0d (expect 0)", acc_out);

#20 $finish;
++end

endmodule