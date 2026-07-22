`timescale 1ns / 1ps

module top ();

logic CLK_200;
logic CLK_50;
logic RST;

logic to_rc;
logic from_rc;

logic tx_o;

initial begin
  $dumpfile("dump.vcd");
  $dumpvars();
  CLK_200 = 1;
  CLK_50  = 0;
  RST     = 1;

  #25 RST = 0;
  #1000000;
  $finish(0);  // 0 = normal termination
  #0;
  $finish;     // Double-tap
end

always begin
  #5 CLK_200 = ~CLK_200;
end
always begin
  #20 CLK_50  = ~CLK_50;
end

RC_model #(
  .TAU(1000), // all in ns
  .ANALOG_IN(0.1),
  .EXT_DELAY(20)
) EXT_model (
  .to_rc_i(to_rc),
  .from_rc_o(from_rc)
);

adc_top_verif_wrap DUT (
  .CLK_200(CLK_200),
  .CLK_50(CLK_50),
  .RST(RST),
  .to_rc(to_rc),
  .from_rc(from_rc),
  .tx_o(tx_o)
);

endmodule
