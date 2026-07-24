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
    .fifo_rdy(1'b1)
);

//byte packer and uart logic

logic [15:0] sample_fifo;
logic [01:0] send_rdy;
logic [07:0] byte_packed;
logic        sample_fifo_rdy;
logic        uart_rdy;
logic        byte_vld;


assign sample_fifo_rdy = (send_rdy[1] == 1'b0);

always_ff @(posedge CLK_50) begin
    if (RST) begin
        sample_fifo <= '0;
        send_rdy <= '0;
    end else begin
        if (sample_vld) begin

            case (send_rdy)
                2'b00:
                    sample_fifo <= {sample_fifo[15:12], sample_processed};
                2'b01:
                    sample_fifo <= {sample_processed[3:0], sample_fifo[11:8], sample_processed[7:0]};
            endcase

            byte_vld <= '1;
            send_rdy <= send_rdy + 2'b01;

        end else if (uart_rdy) begin
            if (send_rdy==2'b10)
                send_rdy <= send_rdy + 2'b01;
            if (send_rdy==2'b11 || send_rdy==2'b00)
                byte_vld <= 0;
        end
    end
end

always_comb begin
    if (send_rdy[1])
            byte_packed = sample_fifo[15:8];
    else
            byte_packed = sample_fifo[7:0]; 
end

not_my_uart_tx #(
/*
NUM_CLK is a half of bit length measured in clock periods.
60 MHz clk_i
1-2 MHz bit frequency (1/period)
1 bit is 30 clk periods
0.5 bit is 15-16 clk periods
*/
  .NUM_CLK(30)
) UART (
  .clk_i(CLK_50),
  .rst_i(RST),
  .data_i(sample_fifo[15:8]),
  .valid_i(byte_vld),
  .ready_o(uart_rdy),
  .tx_o(tx_o)
);
endmodule
