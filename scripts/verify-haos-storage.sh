#!/bin/sh
set -eu

TESTFILE=/data/nvme-speed-test.bin
NVME_PCI=$(basename "$(readlink -f /sys/class/nvme/nvme0/device)")

echo "=== PCIe link ==="
echo "PCI device: $NVME_PCI"
echo -n "Current speed: "
cat "/sys/bus/pci/devices/$NVME_PCI/current_link_speed"
echo -n "Current width: x"
cat "/sys/bus/pci/devices/$NVME_PCI/current_link_width"
echo -n "Maximum speed: "
cat "/sys/bus/pci/devices/$NVME_PCI/max_link_speed"
echo -n "Maximum width: x"
cat "/sys/bus/pci/devices/$NVME_PCI/max_link_width"

echo
echo "=== 4 GiB write ==="
sync
time dd if=/dev/zero of="$TESTFILE" bs=4M count=1024 oflag=direct
sync

echo
echo "=== 4 GiB read ==="
time dd if="$TESTFILE" of=/dev/null bs=4M iflag=direct

rm -f "$TESTFILE"
sync
echo "Temporary test file removed."
