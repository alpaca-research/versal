# iWave iG-RainboW-G77D / G77M on PRHSD R2.0
# Source: iWave Vivado 25.2 FPGA User Guide, Table 6.
# Both LEDs are active-low on the tested carrier.

set_property PACKAGE_PIN AP44 [get_ports {User_LED_tri_o[0]}]
set_property PACKAGE_PIN AP45 [get_ports {User_LED_tri_o[1]}]
set_property IOSTANDARD LVCMOS12 [get_ports {User_LED_tri_o[*]}]
