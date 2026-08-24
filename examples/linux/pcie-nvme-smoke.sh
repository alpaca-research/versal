#!/bin/sh
set -eu

mount_path="${1:-/run/media/nvme0n1p1}"
size_mib="${2:-10}"

case "$size_mib" in
    ''|*[!0-9]*)
        echo "Usage: $0 [mounted-nvme-path] [size-MiB]" >&2
        exit 64
        ;;
esac
if [ "$size_mib" -lt 1 ] || [ "$size_mib" -gt 1024 ]; then
    echo "Size must be between 1 and 1024 MiB" >&2
    exit 64
fi
if [ ! -d "$mount_path" ]; then
    echo "Mount directory does not exist: $mount_path" >&2
    exit 66
fi
if ! command -v findmnt >/dev/null 2>&1; then
    echo "findmnt is required" >&2
    exit 69
fi

resolved_mount=$(readlink -f "$mount_path")
source_device=$(findmnt -n -o SOURCE --target "$resolved_mount")
case "$source_device" in
    /dev/nvme*) ;;
    *)
        echo "Refusing test: $resolved_mount is mounted from $source_device, not NVMe" >&2
        exit 65
        ;;
esac
if [ ! -w "$resolved_mount" ]; then
    echo "Mount is not writable: $resolved_mount" >&2
    exit 73
fi

test_file=""
cleanup() {
    if [ -n "$test_file" ] && [ -f "$test_file" ]; then
        rm -f -- "$test_file"
    fi
}
trap cleanup EXIT HUP INT TERM

test_file=$(mktemp "$resolved_mount/alpaca-pcie-smoke.XXXXXX")
echo "Writing $size_mib MiB to temporary file $test_file"
dd if=/dev/zero of="$test_file" bs=1M count="$size_mib" conv=fsync

expected_bytes=$((size_mib * 1024 * 1024))
actual_bytes=$(stat -c %s "$test_file")
if [ "$actual_bytes" -ne "$expected_bytes" ]; then
    echo "Size mismatch: expected $expected_bytes, got $actual_bytes" >&2
    exit 74
fi

echo "Reading the temporary file back"
dd if="$test_file" of=/dev/null bs=1M
cleanup
test_file=""
echo "NVMe filesystem smoke test passed; temporary file removed"
