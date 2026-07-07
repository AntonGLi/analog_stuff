`timescale 1ns / 1ps

module top ();

logic CLK_200;
logic CLK_60;
logic RST;

logic to_rc;
logic from_rc;

logic [11:0] sample_processed;
logic sample_vld;
logic fifo_rdy;

initial begin
  $dumpfile("dump.vcd");
  $dumpvars();
  CLK_200 = 0;
  CLK_60  = 0;
  RST     = 1;

  #20 RST = 0;
  #100000000  $finish();
end

always begin
  #5 CLK_200 = ~CLK_200;
end
always begin
  #16.667 CLK_60  = ~CLK_60;
end

RC_model #(
  .TAU(1000), // all in ns
  .ANALOG_IN(0),
  .EXT_DELAY(20)
) EXT_model (
  .to_rc_i(to_rc),
  .from_rc_o(from_rc)
);

adc_top_verif_wrap DUT (.*);

endmodule
