module adc_fpga_top (
    input   logic CLK_50,
    input   logic RST,

    output  logic to_rc,
    input   logic from_rc,
    
    output  logic tx_o
);

// PLL IP integration

logic CLK_200;





// main blocks instantiation

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

logic [11:0] sample_processed;
logic sample_vld;

sample_processor DSP (
    .CLK_SLOW(CLK_50),
    .RST(RST),
    .sample_change_toggle(sample_change_toggle),
    .sample_i(sample_raw),
    .sample_o(sample_processed),
    .sample_vld(sample_vld),
    .fifo_rdy(sample_fifo_rdy)
);

//byte packer and uart logic

logic [01:0] send_rdy;
logic [07:0] byte_packed;
logic        sample_fifo_rdy;
logic        uart_rdy;
logic        byte_vld;

buf_12_to_8 byte_packer (
    .CLK(CLK_50),
    .RST(RST),
    .bus_12b_i(sample_processed),
    .bus_12b_vld_i(sample_vld),
    .bus_12b_rdy_o(sample_fifo_rdy),
    .bus_8b_o(byte_packed),
    .bus_8b_rdy_i(uart_rdy),
    .bus_8b_vld_o(byte_vld)
);

not_my_uart_tx #(
/*
NUM_CLK is a half of bit length measured in clock periods.
60 MHz clk_i
1-2 MHz bit frequency (1/period)
1 bit is 30 clk periods
0.5 bit is 15-16 clk periods
*/
  .NUM_CLK(80)
) UART (
  .clk_i(CLK_50),
  .rst_i(RST),
  .data_i(byte_packed),
  .valid_i(byte_vld),
  .ready_o(uart_rdy),
  .tx_o(tx_o)
);
endmodule
