# Build the custom U-Boot

## Base version

Verified source:

```text
Debian u-boot 2025.01-3
board defconfig: rock-4se-rk3399_defconfig
```

The working build was based on the Debian source tree, not an arbitrary vendor fork.

## Required packages

On Armbian/Debian:

```bash
sudo apt update
sudo apt install -y \
  build-essential bc bison flex device-tree-compiler \
  libssl-dev libgnutls28-dev python3-pyelftools \
  swig python3-dev arm-trusted-firmware mtd-utils git
```

Install or unpack the Debian U-Boot 2025.01 source so that the source directory is, for example:

```text
$HOME/u-boot-haos-build/u-boot-2025.01
```

Use an out-of-tree build directory:

```text
$HOME/u-boot-haos-build/build-rock4se
```

## Configure the board

```bash
cd "$HOME/u-boot-haos-build/u-boot-2025.01"
make O="$HOME/u-boot-haos-build/build-rock4se" rock-4se-rk3399_defconfig
```

## Add the `fileenv` command

Apply the included patch:

```bash
git apply /path/to/this-repository/patches/0001-add-fileenv-command.patch
```

The HAOS boot script uses `fileenv` to read a small file into a U-Boot environment variable. Debian's stock build did not provide it.

## Enable all required options

Run:

```bash
/path/to/this-repository/scripts/configure-uboot.sh \
  "$HOME/u-boot-haos-build/build-rock4se"
```

The required settings are:

```text
CONFIG_CMD_FILEENV=y
CONFIG_CMD_SETEXPR=y
CONFIG_CMD_SQUASHFS=y
CONFIG_FS_SQUASHFS=y
CONFIG_LZO=y
CONFIG_CMD_FS_GENERIC=y
CONFIG_USE_PREBOOT=y
CONFIG_PREBOOT="pci enum; nvme scan"
```

Why each option is needed:

- `CMD_FILEENV`: reads HAOS configuration values from files.
- `CMD_SETEXPR`: used by the HAOS boot script for arithmetic/string expressions.
- `CMD_SQUASHFS` and `FS_SQUASHFS`: read the HAOS kernel slot partition.
- `LZO`: HAOS kernel SquashFS was compressed using LZO.
- `CMD_FS_GENERIC`: provides generic `load`/filesystem access used by the script.
- `PREBOOT`: probes PCIe and NVMe before bootflow and the HAOS script run.

## Build with ARM Trusted Firmware

The correct RK3399 BL31 path on the tested Debian installation was:

```text
/usr/lib/arm-trusted-firmware/rk3399/bl31.elf
```

Build:

```bash
/path/to/this-repository/scripts/build-uboot.sh \
  "$HOME/u-boot-haos-build/u-boot-2025.01" \
  "$HOME/u-boot-haos-build/build-rock4se"
```

A warning that `tee-os` is missing is acceptable when it explicitly says the image remains functional. A missing `atf-bl31` is not acceptable.

Expected output file:

```text
$HOME/u-boot-haos-build/build-rock4se/u-boot-rockchip-spi.bin
```

Verify embedded features:

```bash
strings "$HOME/u-boot-haos-build/build-rock4se/u-boot-rockchip-spi.bin" | \
  grep -Ei 'fileenv|setexpr|sqfsload|sqfsls|squashfs|lzo|preboot='
```
