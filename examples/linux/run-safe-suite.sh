#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

run_example() {
    name="$1"
    shift
    printf '\n############################################################\n'
    printf '# %s\n' "$name"
    printf '############################################################\n'
    "$@"
}

run_example "Platform information" "$script_dir/platform-info.sh"
run_example "PCIe status" "$script_dir/pcie-status.sh"
run_example "Video status" "$script_dir/video-status.sh"
run_example "DIP switches" "$script_dir/dip-switches.sh"
run_example "User LEDs" "$script_dir/gpio-led-demo.sh" 8 0.4

echo
echo "Safe board example suite completed"
