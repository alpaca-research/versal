#!/bin/sh
set -eu

led="${1:-D10}"
cycles="${2:-10}"
half_period="${3:-0.5}"

case "$led" in
    D10|d10) gpio=544 ;;
    D8|d8) gpio=545 ;;
    *)
        echo "Usage: $0 [D10|D8] [cycles] [half-period-seconds]" >&2
        exit 64
        ;;
esac

gpio_dir="/sys/class/gpio/gpio$gpio"
if [ ! -d "$gpio_dir" ]; then
    echo "$gpio" > /sys/class/gpio/export
fi
echo out > "$gpio_dir/direction"

i=0
while [ "$i" -lt "$cycles" ]; do
    echo 0 > "$gpio_dir/value"
    sleep "$half_period"
    echo 1 > "$gpio_dir/value"
    sleep "$half_period"
    i=$((i + 1))
done

# Both user LEDs are active-low. Leave the selected LED off.
echo 1 > "$gpio_dir/value"
echo "$led blink completed on GPIO $gpio"
