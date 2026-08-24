#!/bin/sh
set -eu

section() {
    printf '\n== %s ==\n' "$1"
}

section "Platform"
if [ -r /proc/device-tree/model ]; then
    printf 'Model: '
    tr -d '\000' < /proc/device-tree/model
    printf '\n'
fi
uname -a

section "CPU"
lscpu

section "Memory"
free -h

section "RTC"
hwclock -r || true

section "OSPI partition map (read-only)"
cat /proc/mtd

section "Block devices"
lsblk

section "I2C buses"
if command -v i2cdetect >/dev/null 2>&1; then
    i2cdetect -l
else
    echo "i2cdetect is not installed"
fi

section "PCIe"
if command -v lspci >/dev/null 2>&1; then
    lspci -nn
else
    echo "lspci is not installed"
fi

section "USB"
if command -v lsusb >/dev/null 2>&1; then
    lsusb
else
    echo "lsusb is not installed"
fi

section "Network links"
if command -v ip >/dev/null 2>&1; then
    ip -br link
else
    echo "ip is not installed"
fi
