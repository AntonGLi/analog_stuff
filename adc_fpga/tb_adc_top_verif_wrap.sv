module adc_top_verif_wrap (
    input   logic CLK_200,
    input   logic CLK_60,
    input   logic RST,

    output  logic to_rc,
    input   logic from_rc,
    
    output  logic [11:0] sample_processed,
    output  logic sample_vld,
    input   logic fifo_rdy
);

logic sample_change_toggle;
logic [7:0] sample_raw;

adc ADC (
    .CLK_200(CLK_200),
    .RST(RST),
    .to_rc(to_rc),
    .from_rc(from_rc),
    .sample_raw(sample_raw),
    .sample_change_toggle(sample_change_toggle)
);

sample_processor DSP (
    .CLK_SLOW(CLK_60),
    .RST(RST),
    .sample_change_toggle(sample_change_toggle),
    .sample_i(sample_raw),
    .sample_o(sample_processed),
    .sample_vld(sample_vld),
    .fifo_rdy(fifo_rdy)
);

endmodule