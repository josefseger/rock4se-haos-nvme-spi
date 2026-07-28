# Hardware and SPI prerequisites

## Board

This procedure targets the **Radxa ROCK 4 SE**. Do not assume the same image or device-tree settings are correct for another ROCK 4 variant.

## SPI NOR

Verified device:

```text
Winbond W25Q128
capacity: 16 MiB
JEDEC ID: ef4018
Linux MTD device: /dev/mtd0
```

The chip must be soldered correctly to the SPI footprint, including any board components required by the ROCK 4 SE schematic for that footprint. Inspect orientation carefully before applying power.

## UART

Use a 3.3 V UART adapter and set the terminal to:

```text
1500000 baud
8 data bits
no parity
1 stop bit
```

UART is strongly recommended. It is the only practical way to see whether the failure is in TPL, SPL, U-Boot, the HAOS boot script, or the Linux kernel.

## Temporary Armbian system

Boot Armbian from microSD while building and flashing. The NVMe may remain installed.

## Enable SPI NOR in Armbian

Edit `/boot/armbianEnv.txt` and ensure these settings exist:

```ini
overlay_prefix=rockchip
overlays=rk3399-spi-jedec-nor
param_spinor_spi_bus=1
param_spinor_max_freq=1000000
```

The critical setting on the tested board was:

```ini
param_spinor_max_freq=1000000
```

At 10 MHz, long writes verified incorrectly at varying offsets. At 1 MHz, repeated full-image verification was exact.

Reboot Armbian, then verify:

```bash
cat /proc/mtd
sudo dmesg | grep -iE 'spi|mtd|jedec|w25q'
```

Expected: a 16 MiB MTD device at `/dev/mtd0`.
