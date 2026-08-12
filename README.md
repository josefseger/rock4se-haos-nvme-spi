# Home Assistant OS on ROCK 4 SE: SPI boot + NVMe

A concise, reproducible guide for booting **Home Assistant OS (HAOS)** directly from an NVMe SSD on a **Radxa ROCK 4 SE** that has a **16 MiB SPI NOR flash chip soldered to the board**.

This repository documents a configuration that was built, flashed, and verified on real hardware.

## What this solves

The ROCK 4 SE can run HAOS from NVMe, but a board without factory-fitted SPI flash cannot start from NVMe by itself. Adding SPI NOR and flashing a suitable U-Boot creates this boot chain:

```text
RK3399 Boot ROM -> SPI U-Boot -> PCIe/NVMe -> HAOS boot.scr -> HAOS kernel -> HAOS system
```

The stock Debian U-Boot 2025.01 was close, but HAOS also required:

- early PCIe/NVMe initialization;
- `fileenv` support;
- `setexpr` support;
- SquashFS support;
- LZO decompression support.

## Verified hardware

- Radxa ROCK 4 SE, RK3399, 4 GB RAM
- 16 MiB Winbond W25Q128 SPI NOR, JEDEC ID `ef4018`
- WD PC SN530 NVMe 256 GB
- Armbian used temporarily for building and flashing
- UART console at **1,500,000 baud** for U-Boot diagnostics

## Verified result

- Boots HAOS from NVMe with no SD card inserted
- PCIe link: **Gen 2 x4**, `5.0 GT/s`, four lanes
- Measured 4 GiB sequential performance:
  - write: approximately **360 MB/s**
  - read: approximately **1.2 GB/s**

## Verified prebuilt SPI image

The exact U-Boot image built and verified on the tested ROCK 4 SE is included in this repository:

- [`firmware/u-boot-rockchip-spi.bin`](firmware/u-boot-rockchip-spi.bin)
- [`firmware/SHA256SUMS`](firmware/SHA256SUMS)

Image details:

```text
File:   u-boot-rockchip-spi.bin
Size:   2,227,712 bytes
SHA256: 85dc5a58abe48063b2c42b2d9541c9c44aca73fb87ba0685631b75f5c0d9d95b
```

This is the custom HAOS-capable build with early PCIe/NVMe initialization, `fileenv`, `setexpr`, SquashFS, LZO and generic filesystem support enabled.

Before flashing, verify the downloaded image:

```bash
cd firmware
sha256sum -c SHA256SUMS
```

Expected result:

```text
u-boot-rockchip-spi.bin: OK
```

The image was flashed to a 16 MiB SPI NOR at a configured SPI maximum frequency of **1 MHz**, then independently read back from `/dev/mtd0`; the source image and SPI readback were byte-identical and had the same SHA-256 shown above.

## Repository map

- [`firmware/u-boot-rockchip-spi.bin`](firmware/u-boot-rockchip-spi.bin) — verified prebuilt HAOS-capable SPI U-Boot image
- [`firmware/SHA256SUMS`](firmware/SHA256SUMS) — SHA-256 checksum for the prebuilt image
- [`docs/hardware.md`](docs/hardware.md) — hardware assumptions and SPI setup
- [`docs/build.md`](docs/build.md) — build the custom U-Boot
- [`docs/flash.md`](docs/flash.md) — safely flash and verify SPI
- [`docs/haos.md`](docs/haos.md) — prepare HAOS on NVMe and first boot
- [`docs/verify.md`](docs/verify.md) — verify boot and PCIe/NVMe performance
- [`docs/troubleshooting.md`](docs/troubleshooting.md) — exact symptoms and fixes
- [`patches/0001-add-fileenv-command.patch`](patches/0001-add-fileenv-command.patch) — HAOS-compatible `fileenv` command
- [`scripts/configure-uboot.sh`](scripts/configure-uboot.sh) — apply required U-Boot options
- [`scripts/build-uboot.sh`](scripts/build-uboot.sh) — build with RK3399 BL31
- [`scripts/flash-spi.sh`](scripts/flash-spi.sh) — erase, write, and verify SPI twice
- [`scripts/verify-haos-storage.sh`](scripts/verify-haos-storage.sh) — report PCIe link and benchmark `/data`

## Important warnings

- Soldering SPI NOR can permanently damage the board.
- Flashing the wrong image to SPI can prevent normal boot.
- On the tested board, long SPI writes were unreliable at 10 MHz. **1 MHz was stable and verified.**
- Never interrupt power during SPI erase or write.
- Always make a complete SPI backup and perform two readback comparisons before rebooting.

## Quick outline

1. Solder and expose the 16 MiB SPI NOR.
2. Boot Armbian from SD.
3. Enable the SPI NOR overlay at 1 MHz.
4. Build Debian U-Boot 2025.01 for `rock-4se-rk3399`, or use the verified prebuilt image in `firmware/`.
5. Add `fileenv` and enable the HAOS-required commands and filesystems when rebuilding.
6. Build with RK3399 ARM Trusted Firmware `bl31.elf` when rebuilding.
7. Flash U-Boot to `/dev/mtd0` and verify it twice.
8. Flash the HAOS ROCK 4 image to NVMe.
9. Remove SD and boot HAOS from NVMe.

See the individual documents for copy-paste commands.
