#!/bin/sh
set -eu

read_dip() {
    gpio="$1"
    if [ ! -d "/sys/class/gpio/gpio$gpio" ]; then
        echo "$gpio" > /sys/class/gpio/export
    fi
    echo in > "/sys/class/gpio/gpio$gpio/direction"
    value=$(cat "/sys/class/gpio/gpio$gpio/value")
    echo "SW6 GPIO $gpio = $value"
}

read_dip 542
read_dip 543

echo "Move either SW6 position and rerun this script to observe the change."
