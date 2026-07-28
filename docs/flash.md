# Flash U-Boot to SPI safely

## Preconditions

- Armbian is running from SD.
- `/dev/mtd0` is the 16 MiB SPI NOR.
- SPI frequency is configured to 1 MHz.
- The new image built successfully with BL31.
- Power is stable.

## Automated flash and verification

Run as root or through `sudo`:

```bash
sudo /path/to/this-repository/scripts/flash-spi.sh \
  "$HOME/u-boot-haos-build/build-rock4se/u-boot-rockchip-spi.bin"
```

The script performs:

1. size and device checks;
2. complete 16 MiB backup;
3. full SPI erase;
4. image write;
5. two independent readbacks;
6. SHA-256 output;
7. byte-for-byte `cmp` verification.

Do not reboot unless both readbacks are exact.

## Manual reference

```bash
IMAGE="$HOME/u-boot-haos-build/build-rock4se/u-boot-rockchip-spi.bin"
SIZE=$(stat -c '%s' "$IMAGE")

sudo mtd_debug read /dev/mtd0 0 16777216 "$HOME/spi-backup.bin"
sudo flash_erase /dev/mtd0 0 0
sudo mtd_debug write /dev/mtd0 0 "$SIZE" "$IMAGE"
sudo mtd_debug read /dev/mtd0 0 "$SIZE" /tmp/spi-readback-1.bin
sudo mtd_debug read /dev/mtd0 0 "$SIZE" /tmp/spi-readback-2.bin

sha256sum "$IMAGE" /tmp/spi-readback-1.bin /tmp/spi-readback-2.bin
cmp "$IMAGE" /tmp/spi-readback-1.bin
cmp "$IMAGE" /tmp/spi-readback-2.bin
cmp /tmp/spi-readback-1.bin /tmp/spi-readback-2.bin
```
