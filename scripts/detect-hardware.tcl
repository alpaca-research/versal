# Detect the exact Versal device without changing its configuration.

if {$argc < 1 || $argc > 2} {
    puts stderr "Usage: detect-hardware.tcl <hw_server_url> ?device_pattern?"
    exit 64
}

set hw_server_url [lindex $argv 0]
set device_pattern "xc2ve3858*"
if {$argc == 2} {
    set device_pattern [lindex $argv 1]
}

set target_open 0
set server_connected 0

set status [catch {
    open_hw_manager
    connect_hw_server -url $hw_server_url
    set server_connected 1
    open_hw_target
    set target_open 1

    puts "ALPACA: connected hardware targets"
    foreach target [get_hw_targets -quiet] {
        puts "  target: [get_property NAME $target]"
    }

    puts "ALPACA: JTAG devices"
    foreach device [get_hw_devices -quiet] {
        set name [get_property NAME $device]
        set part [get_property PART $device]
        puts "  device: $name (part: $part)"
    }

    set matches [get_hw_devices -quiet $device_pattern]
    set count [llength $matches]
    if {$count != 1} {
        error "expected exactly one device matching '$device_pattern'; found $count"
    }

    set device [lindex $matches 0]
    current_hw_device $device
    refresh_hw_device -update_hw_probes false $device
    puts "ALPACA: exact device match: [get_property NAME $device]"
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

puts "ALPACA: detection completed without programming"
exit 0
