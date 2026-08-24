if {$argc != 2} {
    puts stderr "Usage: simulate.tcl <repository_root> <simulation_directory>"
    exit 64
}

set repository_root [file normalize [lindex $argv 0]]
set simulation_directory [file normalize [lindex $argv 1]]
set rtl_file [file join $repository_root rtl alpaca_led_blink.sv]
set testbench_file [file join $repository_root sim tb_alpaca_led_blink.sv]

if {![file isfile $rtl_file] || ![file isfile $testbench_file]} {
    puts stderr "ALPACA ERROR: RTL or testbench file is missing"
    exit 66
}

# Behavioral simulation does not need an implementation part. Keeping this
# project part-independent lets lean installations run the smoke test even
# when the full 2VE3858 implementation database is not installed.
create_project alpaca_rtl_test $simulation_directory -force
add_files -norecurse $rtl_file
add_files -fileset sim_1 -norecurse $testbench_file
set_property top tb_alpaca_led_blink [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

launch_simulation -simset sim_1 -mode behavioral
close_sim
close_project
puts "ALPACA: Vivado RTL simulation completed"
exit 0
