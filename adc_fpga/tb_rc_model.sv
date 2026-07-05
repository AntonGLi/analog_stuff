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

  fork
    forever begin
      #1 rc = rc + drc_dt * 1;

      if (to_rc)
        drc_dt = ( max_v - rc) / tau; // [V/ns]
      else
        drc_dt = (-max_v - rc) / tau;

      delay = (ANALOG_IN - rc) / drc_dt;
    end

    begin
      #0.001 //for predictability of delay calculation
      forever begin
        if (delay < 1)
          #delay from_rc = (rc > ANALOG_IN); #(1-delay) //total delay of this condition is still 1 ns
        else
          #1
      end
    end
  join
end

always @(from_rc) begin
  from_rc_o = #EXT_DELAY from_rc;
end

endmodule
