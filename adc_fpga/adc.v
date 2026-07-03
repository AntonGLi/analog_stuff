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
    input   logic from_hf_cnt,   
    input   logic from_rc,
    output  logic sample,
    output  logic vld
    //rdy?
);
    logic [6:0] rise_val;
    logic [6:0] fall_val;

    always_ff @(posedge CLK_200) begin
        if (RST) begin
            rise_val <= '0;
            fall_val <= '0;
        end else begin
            if (from_hf_cnt[7]) begin
                rise_val <=
            end
        end 
    end
endmodule