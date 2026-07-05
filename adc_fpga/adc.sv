module adc (
    input   logic CLK_200,
    input   logic RST,

    output  logic to_rc,
    input   logic from_rc,
    
    output  logic [7:0] sample_raw,
    output  logic sample_change_toggle,
);

logic [7:0] from_hf_cnt;

hf_counter CNT_1 (
    .CLK_200(CLK_200),
    .RST(RST),
    .to_rc(to_rc),
    .cnt(from_hf_cnt) 
);

sampler ADC_CORE (
    .CLK_200(CLK_200),
    .RST(RST),
    .from_hf_cnt(from_hf_cnt),   
    .from_rc(from_rc),
    .sample_buf(sample_raw),
    .sample_change_toggle(sample_change_toggle)
);

endmodule

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
    output  logic [7:0] sample_buf,
    output  logic sample_change_toggle
);

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

    // RISE FALL ARRIVAL TIME FIXATION

    logic [7:0] rise_val;
    logic [7:0] fall_val;

    always_ff @(posedge CLK_200) begin
        if (RST) begin
            rise_val <= '0;
            fall_val <= '0;
        end else begin
            if (to_rc && from_rc_change)
                rise_val <= from_hf_cnt[7:0];                
            if (~to_rc && from_rc_change)
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

    // SAMPLE CALCULATION

    wire  sample [7:0] = rise_val - fall_val;

    wire  sample_change = ~to_rc & to_rc_change;

    always_ff @(posedge CLK_200) begin
        if (RST)
            sample_buf <= 0;
        else if (sample_change)
            sample_buf <= sample;
    end
    
    // OUTPUT INTERFACE LOGIC

  logic sample_change_toggle;

    always_ff @(posedge CLK_200) begin
        if (RST)
            sample_change_toggle <= 0;
        else if (sample_change)
            sample_change_toggle <= ~sample_change_toggle;
    end

endmodule

module sample_processor (
    input   logic           CLK_SLOW,
    input   logic           RST,
    input   logic           sample_change_toggle,
    input   logic [7:0]     sample_i,
    output  logic [11:0]    sample_o,
    output  logic           sample_vld,
    output  logic           fifo_rdy
);

    //READ SAMPLE

    logic sample_change_toggle_buf1;
    logic sample_change_toggle_buf2;

    logic [7:0] sample_buf;

    always_ff @(posedge CLK_SLOW) begin
        if (RST)
            sample_change_toggle_buf1 <= 0;
            sample_change_toggle_buf2 <= 0;
        else
            sample_change_toggle_buf1 <= sample_change_toggle;
            sample_change_toggle_buf2 <= sample_change_toggle_buf1;
    end

    wire sample_read_en = sample_change_toggle_buf2 ^ sample_change_toggle_buf1;

    always_ff @(posedge CLK_SLOW) begin
        if (RST)
            sample_buf <= 0;
        else if (sample_read_en)
            sample_buf <= sample_i;
    end

    //ACCUMULATE FOR MORE BITS SAMPLE 

    logic [11:0]    accumulator;
    logic           accumulator_sum_en;
    logic [3:0]     sum_16;

    always_ff @(posedge CLK_SLOW) begin
        if (RST)
            accumulator_sum_en <= 0;
        else
            accumulator_sum_en <= sample_read_en;
    end

    always_ff @(posedge CLK_SLOW) begin
        if (RST)
            sum_16 <= '0;
        else if (accumulator_sum_en)
            sum_16 <= sum_16 + 4'b1;
    end

    always_ff @(posedge CLK_SLOW) begin
        if (RST)
            accumulator <= '0;
        else if (sum_16 == '1)
            accumulator <= '0;
        else if (accumulator_sum_en)
            accumulator <= accumulator + {4'b0, sample_buf};
    end

    // OUT BUFFER AND VLD/RDY INTERFACE

    always_ff @(posedge CLK_SLOW) begin
        if (RST) begin
            sample_o <= '0;
            sample_vld <= '0;
        end else if (sum_16 == '1) begin
            sample_o <= accumulator;
            sample_vld <= 1;
        end else if (fifo_rdy)
            sample_vld <= 0;
    end

endmodule
