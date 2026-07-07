`timescale 1ns / 1ps

module RC_model #(
  parameter shortreal TAU = 1000, // all in ns
  parameter shortreal ANALOG_IN = 0,
  parameter shortreal EXT_DELAY = 20
) (
  input  logic to_rc_i,
  output logic from_rc_o
);

logic from_rc;
logic virt_clk_1000mhz;

shortreal rc;
shortreal drc_dt;
shortreal delay;
shortreal max_v = 3.3/2; // relatively to its average i.e. 3.3/2 V

// every 1 ns check for to_rc
// calculate derivative d(rc)/dt
// calculate next rc value 
// calculate delay
// if 0 < delay < 1 ns then apply it and execute transient of from_rc

initial begin
  rc     = -max_v;
  drc_dt = 0;
  virt_clk_1000mhz=1;

  fork
    forever begin
      #1 rc = rc + drc_dt * 1;

      if (to_rc_i)
        drc_dt = ( max_v - rc) / TAU; // [V/ns]
      else
        drc_dt = (-max_v - rc) / TAU;

      delay = (-ANALOG_IN + rc) / drc_dt;
    end

    begin
      #0.001 //for predictability of delay calculation
      forever begin
        #1 virt_clk_1000mhz=~virt_clk_1000mhz;
      end
    end
  join
end

logic debug_1;
logic debug_2;
assign debug_1 = (rc > ANALOG_IN);
assign debug_2 = (delay < 1) && (delay > 0);
always @(posedge virt_clk_1000mhz) begin
  if ((delay < 1) && (delay > 0)) begin
    from_rc = #delay (rc > ANALOG_IN);
  end
end

always @(from_rc) begin
  from_rc_o = #EXT_DELAY from_rc;
end

endmodule
