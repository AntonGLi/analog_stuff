module hf_counter (
    input   logic CLK_200,
    input   logic RST,
    output  logic to_rc,
    output  logic [7:0] cnt 
);
    assign to_rc = cnt[7];

    always_ff @(posedge CLK_200) begin
        if (RST)
            cnt <= '0;
        else
            cnt <= cnt + 1;
    end
endmodule

module sampler (
    input   logic CLK_200,
    input   logic RST,
    input   logic [7:0] from_hf_cnt,   
    input   logic from_rc,
    output  logic [7:0] sample,
    output  logic VLD_buf,
    input   logic RDY
);

    logic [7:0] rise_val;
    logic [7:0] fall_val;

    // FROM RC CHANGE (RISE FALL) DETECTION 

    logic rc_prev;
    logic from_rc_change;

    wire to_rc = from_hf_cnt[7];

    always_ff @(posedge CLK_200) begin
        if (RST)
            rc_prev <= 1'b0;
        else
            rc_prev <= from_rc;
    end

    assign from_rc_change = rc_prev ^ from_rc;

    // RISE FALL VAL DETECTION

    always_ff @(posedge CLK_200) begin
        if (RST) begin
            rise_val <= '0;
            fall_val <= '0;
        end else begin
            if (to_rc && from_rc_change)
                rise_val <= from_hf_cnt[7:0];                
            if (to_rc && from_rc_change)
                fall_val <= from_hf_cnt[7:0];
        end 
    end

    // PERIOD DETECTION

    logic to_rc_prev; //only msb

    always_ff @(posedge CLK_200) begin
        if (RST)
            to_rc_prev <= 0;
        else
            to_rc_prev <= to_rc;
    end

    wire to_rc_change = to_rc ^ to_rc_prev;

    // SAMPLE PROCESSING

    wire DUTY [7:0] = rise_val - fall_val;

    always_ff @(posedge CLK_200) begin
        if (RST)
            sample <= 0;
        else if (to_rc & to_rc_change)
            sample <= DUTY;
    end

    // OUTPUT INTERFACE LOGIC

    assign VLD = (~to_rc & to_rc_change);

    logic VLD_buf;

    // rdy logic

    always_ff @(posedge CLK_200) begin
        if (RST)
            VLD_buf <= 0;
        else if (RDY)
            VLD_buf <= 0;
        else if (to_rc & to_rc_change)
            VLD_buf <= 1;
    end

    always_ff @(posedge CLK_200) begin
        if (RST)
            sample <= 0;
        else if (to_rc & to_rc_change)
            sample <= DUTY;
    end

endmodule

module FPGA_OUT (
    input   logic CLK_50,
    input   logic VLD,
    input   logic RST,
    output  logic RDY,
    input   logic [7:0] sample,
    output //interface to computer
);

    always_ff @(posedge CLK_50) begin
        if (RST)
            RDY <= 0;
        else if (VLD)
            RDY <= 0;
        else
            RDY <= 1;
    end

    logic [7:0] sample_buf;

    always_ff @(posedge CLK_50) begin
        if (RST)
            sample_buf <= 0;
        else if (VLD)
            sample_buf <= sample;
    end

endmodule