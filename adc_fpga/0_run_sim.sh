iverilog -g2012 -s tb_12_to_8_bit *.sv
#iverilog -g2012 -s top *.sv
vvp a.out
gtkwave dump.vcd 