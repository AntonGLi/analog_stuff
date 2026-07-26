`timescale 1ns / 1ps

module tb_12_to_8_bit;

logic CLK_50;
logic RST;

logic to_rc;
logic from_rc;

logic tx_o;

initial begin
  $dumpfile("dump.vcd");
  $dumpvars();
  CLK_50  = 0;
  RST     = 1;
  sample_vld = 0;

  #25 RST = 0;
  #1000000;
  $finish(0);  // 0 = normal termination
  #0;
  $finish;     // Double-tap
end


always begin
  #20 CLK_50  = ~CLK_50;
end

logic [11:0] sample_processed;
logic sample_vld;

always begin
  #20000 sample_processed = $urandom_range(0, 4095);
  sample_vld = 1;
end

always @(posedge CLK_50) begin
  if (sample_fifo_rdy)
    sample_vld = 0;
end

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
  .NUM_CLK(30)
) UART (
  .clk_i(CLK_50),
  .rst_i(RST),
  .data_i(byte_packed),
  .valid_i(byte_vld),
  .ready_o(uart_rdy),
  .tx_o(tx_o)
);
endmodule