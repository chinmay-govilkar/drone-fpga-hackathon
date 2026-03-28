// Top-level Drone Detector
// Input:  32x32 spectrogram (1024 pixels, 8-bit each)
// Output: 1 = drone detected, 0 = not drone

module drone_detector (
    input  wire        clk,
    input  wire        rst,
    input  wire        enable,
    input  wire signed [7:0] spectrogram [0:1023], // 32x32 flattened
    output reg         drone_detected,
    output reg         valid
);

    // ── Internal signals ─────────────────────────────
    // After conv1+relu: 32x32x8 feature maps (flattened)
    wire signed [23:0] conv1_out [0:8191];   // 32*32*8
    // After maxpool1: 16x16x8
    wire signed [23:0] pool1_out [0:2047];   // 16*16*8
    // After conv2+relu: 16x16x16
    wire signed [23:0] conv2_out [0:4095];   // 16*16*16
    // After maxpool2+flatten: 1024 values
    wire signed [23:0] pool2_out [0:1023];
    // After dense1: 32 values
    wire signed [23:0] dense1_out [0:31];
    // Final output
    wire signed [23:0] dense2_out;

    // ── State machine ─────────────────────────────────
    reg [2:0] state;
    localparam IDLE=0, CONV1=1, POOL1=2, 
               CONV2=3, POOL2=4, DENSE=5, DONE=6;

    // ── Conv1 weights (from extract_weights.py) ───────
    // Layer 0, Filter 0 — 3x3x1 = 9 weights
    // Replace these with your actual int8 weights!
    reg signed [7:0] conv1_w0 [0:8];
    reg signed [7:0] conv1_bias;

    // ── Process one patch through conv1 ───────────────
    wire signed [23:0] conv1_patch_out;
    wire conv1_valid;
    reg  signed [7:0] curr_patch    [0:8];
    reg  signed [7:0] curr_filter   [0:8];
    reg  signed [7:0] curr_bias;
    reg  conv_enable;

    conv2d conv1_inst (
        .clk(clk), .rst(rst), .enable(conv_enable),
        .patch(curr_patch), .filter_w(curr_filter),
        .bias(curr_bias),
        .data_out(conv1_patch_out), .valid(conv1_valid)
    );

    // ── Dense layer 1: 1024→32 ────────────────────────
    wire signed [23:0] d1_out;
    wire d1_valid;
    reg  d1_enable;
    reg  signed [7:0] d1_weights [0:1023];

    dense #(.N(1024)) dense1_inst (
        .clk(clk), .rst(rst), .enable(d1_enable),
        .data_in(pool2_out), .weights(d1_weights),
        .bias(8'sd0), .apply_relu(1'b1),
        .data_out(d1_out), .valid(d1_valid)
    );

    // ── Dense layer 2: 32→1 ───────────────────────────
    wire signed [23:0] d2_out;
    wire d2_valid;
    reg  d2_enable;
    reg  signed [7:0] d2_weights [0:31];

    dense #(.N(32)) dense2_inst (
        .clk(clk), .rst(rst), .enable(d2_enable),
        .data_in(dense1_out), .weights(d2_weights),
        .bias(8'sd0), .apply_relu(1'b0),
        .data_out(d2_out), .valid(d2_valid)
    );

    // ── Output: positive value = drone ────────────────
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            drone_detected <= 0;
            valid          <= 0;
            state          <= IDLE;
        end
        else begin
            case (state)
                IDLE: if (enable) state <= CONV1;
                CONV1: begin
                    // Convolution handled externally for now
                    state <= POOL1;
                end
                POOL1: state <= CONV2;
                CONV2: state <= POOL2;
                POOL2: begin
                    d1_enable <= 1;
                    state     <= DENSE;
                end
                DENSE: begin
                    if (d2_valid) begin
                        // Positive output = drone
                        drone_detected <= ~d2_out[23];
                        valid          <= 1;
                        state          <= DONE;
                    end
                end
                DONE: valid <= 1;
            endcase
        end
    end

endmodule