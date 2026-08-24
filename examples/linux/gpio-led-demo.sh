#!/bin/sh
set -eu

cycles="${1:-8}"
half_period="${2:-0.4}"

case "$cycles" in
    ''|*[!0-9]*)
        echo "Usage: $0 [cycles] [half-period-seconds]" >&2
        exit 64
        ;;
esac
case "$half_period" in
    ''|*[!0-9.]*|*.*.*)
        echo "Usage: $0 [cycles] [half-period-seconds]" >&2
        exit 64
        ;;
esac

prepare_output() {
    gpio="$1"
    if [ ! -d "/sys/class/gpio/gpio$gpio" ]; then
        echo "$gpio" > /sys/class/gpio/export
    fi
    echo out > "/sys/class/gpio/gpio$gpio/direction"
    echo 1 > "/sys/class/gpio/gpio$gpio/value"
}

leds_off() {
    echo 1 > /sys/class/gpio/gpio544/value 2>/dev/null || true
    echo 1 > /sys/class/gpio/gpio545/value 2>/dev/null || true
}

trap leds_off EXIT HUP INT TERM
prepare_output 544
prepare_output 545

echo "Alternating D10 (GPIO 544) and D8 (GPIO 545) $cycles times"
i=0
while [ "$i" -lt "$cycles" ]; do
    echo 0 > /sys/class/gpio/gpio544/value
    echo 1 > /sys/class/gpio/gpio545/value
    sleep "$half_period"
    echo 1 > /sys/class/gpio/gpio544/value
    echo 0 > /sys/class/gpio/gpio545/value
    sleep "$half_period"
    i=$((i + 1))
done

leds_off
echo "LED example completed; both active-low LEDs are off"
