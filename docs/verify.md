# Verify HAOS, PCIe link, and NVMe speed

Open the HAOS host shell. From the HA CLI use:

```text
login
```

## Confirm the negotiated PCIe link

```sh
NVME_PCI=$(basename "$(readlink -f /sys/class/nvme/nvme0/device)")
echo "PCI device: $NVME_PCI"
echo -n "Current speed: "
cat /sys/bus/pci/devices/$NVME_PCI/current_link_speed
echo -n "Current width: x"
cat /sys/bus/pci/devices/$NVME_PCI/current_link_width
echo -n "Maximum speed: "
cat /sys/bus/pci/devices/$NVME_PCI/max_link_speed
echo -n "Maximum width: x"
cat /sys/bus/pci/devices/$NVME_PCI/max_link_width
```

Expected ROCK 4 SE link:

```text
Current speed: 5.0 GT/s PCIe
Current width: x4
```

That is PCIe Gen 2 x4.

The HAOS boot configuration applied the overlay:

```text
rk3399-pcie-gen2.dtbo
```

## Kernel confirmation

```sh
dmesg | grep -iE 'pcie|pci.*link|nvme'
```

A successful link may report approximately:

```text
16.000 Gb/s available PCIe bandwidth, limited by 5.0 GT/s PCIe x4
```

## 4 GiB practical benchmark

BusyBox `dd` in HAOS may not support `status=progress`.

```sh
TESTFILE=/data/nvme-speed-test.bin

echo "=== 4 GiB write ==="
sync
time dd if=/dev/zero of="$TESTFILE" bs=4M count=1024 oflag=direct
sync

echo "=== 4 GiB read ==="
time dd if="$TESTFILE" of=/dev/null bs=4M iflag=direct

rm -f "$TESTFILE"
sync
```

Verified WD SN530 result on the tested system:

```text
write: 359.7 MB/s
read: 1.2 GB/s
```
