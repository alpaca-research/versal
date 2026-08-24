#!/bin/sh
set -eu

echo "== DRM nodes =="
ls -l /dev/dri 2>&1 || true

echo
echo "== Connector status =="
found=0
for connector in /sys/class/drm/card*-*; do
    [ -r "$connector/status" ] || continue
    found=1
    printf '%s = ' "${connector##*/}"
    cat "$connector/status"
done
[ "$found" -eq 1 ] || echo "No DRM connector status files found"

echo
echo "== V4L2 devices =="
if command -v v4l2-ctl >/dev/null 2>&1; then
    v4l2-ctl --list-devices || true
else
    echo "v4l2-ctl is not installed"
fi

echo
echo "== Xilinx media pipeline =="
if command -v media-ctl >/dev/null 2>&1 && [ -e /dev/media0 ]; then
    media-ctl -d /dev/media0 -p
else
    echo "/dev/media0 or media-ctl is unavailable"
fi
