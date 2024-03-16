create_clock -period 10.0 -name clk [get_ports clk]
#set_input_delay -clock "clk" 0.0 [get_ports en* we* addr* data*]
#set_output_delay -clock "clk" 0.0 [all_outputs]