# Volatile PL programming for the iWave G77D 2VE3858 platform.
# This script does not create or program a configuration-memory device.

if {$argc < 2 || $argc > 3} {
    puts stderr "Usage: program-pl.tcl <pld.pdi> <hw_server_url> ?device_pattern?"
    exit 64
}

set pdi_file [file normalize [lindex $argv 0]]
set hw_server_url [lindex $argv 1]
set device_pattern "xc2ve3858*"
if {$argc == 3} {
    set device_pattern [lindex $argv 2]
}

if {![file isfile $pdi_file]} {
    puts stderr "ALPACA ERROR: PDI does not exist: $pdi_file"
    exit 66
}
if {[string tolower [file extension $pdi_file]] ne ".pdi"} {
    puts stderr "ALPACA ERROR: expected a .pdi file: $pdi_file"
    exit 65
}

set target_open 0
set server_connected 0

set status [catch {
    open_hw_manager
    connect_hw_server -url $hw_server_url
    set server_connected 1
    open_hw_target
    set target_open 1

    set matches [get_hw_devices -quiet $device_pattern]
    set count [llength $matches]
    if {$count != 1} {
        error "expected exactly one device matching '$device_pattern'; found $count"
    }

    set device [lindex $matches 0]
    current_hw_device $device
    refresh_hw_device -update_hw_probes false $device

    puts "ALPACA: target [get_property NAME $device]"
    puts "ALPACA: volatile PL image $pdi_file"
    set_property PROGRAM.FILE $pdi_file $device
    program_hw_devices $device
    refresh_hw_device -update_hw_probes false $device
    verify_hw_devices $device
} message options]

if {$target_open} {
    catch {close_hw_target}
}
if {$server_connected} {
    catch {disconnect_hw_server}
}
catch {close_hw_manager}

if {$status != 0} {
    puts stderr "ALPACA ERROR: $message"
    exit 1
}

puts "ALPACA: PL programming and verification completed"
exit 0
