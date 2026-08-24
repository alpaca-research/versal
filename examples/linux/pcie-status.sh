#!/bin/sh
set -eu

if ! command -v lspci >/dev/null 2>&1; then
    echo "lspci is required" >&2
    exit 69
fi

echo "== PCIe topology =="
lspci -tv

echo
echo "== PCIe devices =="
lspci -nn

echo
echo "== Link information =="
for device_path in /sys/bus/pci/devices/*; do
    [ -e "$device_path/vendor" ] || continue
    address=${device_path##*/}
    vendor=$(cat "$device_path/vendor")
    device=$(cat "$device_path/device")
    class=$(cat "$device_path/class")
    speed="unavailable"
    width="unavailable"
    [ -r "$device_path/current_link_speed" ] && \
        speed=$(cat "$device_path/current_link_speed")
    [ -r "$device_path/current_link_width" ] && \
        width=$(cat "$device_path/current_link_width")
    echo "$address vendor=$vendor device=$device class=$class link=$speed x$width"
done

echo
echo "== NVMe status =="
nvme_lines=$(lspci -Dn | awk '$2 == "0108:" {print}')
if [ -n "$nvme_lines" ]; then
    echo "$nvme_lines"
    if command -v nvme >/dev/null 2>&1; then
        nvme list
    else
        lsblk
    fi
else
    echo "No NVMe endpoint is enumerated."
    echo "Install the endpoint with board power off, then power-cycle and rerun."
fi
