## Generated SDC file "Giraffe_ADC.out.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.1.0 Build 625 09/12/2018 SJ Standard Edition"

## DATE    "Tue Sep 27 11:46:27 2022"

##
## DEVICE  "EP4CE115F29C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk_50M} -period 20 -waveform { 0.000 10.000 } [get_ports {clk_50M}]


#**************************************************************
# Create Generated Clock
#**************************************************************

# create_generated_clock -name {u_my_PLL|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {u_my_PLL|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 5000 -master_clock {clk_50M} [get_pins {u_my_PLL|altpll_component|auto_generated|pll1|clk[0]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {nrst}]
set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {calib_ena_FPGA}]
set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {sw_NOWA[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {sw_NOWA[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {sw_NOWA[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {sw_NOWA[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {sw_NOWA[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {sw_NOWA[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {sw_NOWA[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {sw_NOWA[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {sw_NOWA[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {adc_ack}]
set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {adc_ack_sub}]
set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {dout_adc[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {dout_adc[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {dout_adc[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {dout_adc[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {dout_adc[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {dout_adc[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {rxfM}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_out[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_out[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_out[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_out[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_cnt_send[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_cnt_send[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_cnt_send[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_cnt_send[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_cnt_send[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_cnt_send[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_cnt_send[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_cnt_send[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_cnt_send[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_cnt_send[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_cnt_send[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_cnt_send[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_cnt_send[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_cnt_send[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_cnt_send[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_cnt_send[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_cnt_send[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_cnt_send[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_state[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_state[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_state[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {LED_state[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {tx2M}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {rstn_adc}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {NOWA_adc[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {NOWA_adc[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {NOWA_adc[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {NOWA_adc[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {NOWA_adc[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {NOWA_adc[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {NOWA_adc[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {NOWA_adc[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {NOWA_adc[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {calib_ena_adc}]
set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {adc_ena}]

set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  2.000 [get_ports {cap_rstn}]

set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  1.000 [get_ports {clk_adc}]

set_output_delay -add_delay  -clock [get_clocks {clk_50M}]  1.000 [get_ports {clk_ultra}]

#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

