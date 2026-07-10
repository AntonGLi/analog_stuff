iverilog -g2012 -s top *.sv
vvp a.out
gtkwave dump.vcd 