module adc_top_verif_wrap (
    input   logic CLK_200,
    input   logic CLK_60,
    input   logic RST,

    output  logic to_rc,
    input   logic from_rc,
    
    output  logic tx_o
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

//byte packer logic

logic [11:0] sample_fifo;
logic [07:0] byte_packed;
logic 

always_ff @(posedge CLK_60) begin
    if (RST)
        sample_fifo <= '0
        byte_packed <= '0;
    else begin
        if (sample_vld)
            sample_fifo <= sample_processed;
        
        byte_packed <= 
    end
end


//uart logic


    output  logic [11:0] sample_processed,
    output  logic sample_vld,
    input   logic fifo_rdy

not_my_uart_tx #(
/*
NUM_CLK is a half of bit length measured in clock periods.
60 MHz clk_i
1-2 MHz bit frequency (1/period)
1 bit is 30 clk periods
0.5 bit is 15-16 clk periods
*/
  .NUM_CLK(15)
) UART (
  .clk_i(CLK_60),
  .rst_i(RST),
  .data_i(),
  .valid_i(),
  .ready_o(),
  .tx_o()
);
endmodule

/*
module adc_fpga_top (
    input  logic CLK_50,
    input  logic RST,

    output logic to_rc,
    input  logic from_rc,

    output logic usb_d_plus,
    output logic usb_d_minus,
    output logic 
    
);

sample_processor (
    CLK_SLOW,
    sample_change_toggle,
    sample_i,
    sample_o,
    sample_vld,
    fifo_rdy
);

endmodule
*/