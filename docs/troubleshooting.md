# Troubleshooting by exact symptom

## `Unknown command 'fileenv'`

Cause: stock U-Boot lacks the HAOS-specific `fileenv` command.

Fix: apply `0001-add-fileenv-command.patch` and enable:

```text
CONFIG_CMD_FILEENV=y
```

## `Unknown command 'setexpr'`

Fix:

```text
CONFIG_CMD_SETEXPR=y
```

## `part number ... hassos-kernel0` leaves the variable empty

After stopping autoboot manually, NVMe may not yet be probed. Test:

```text
pci enum
nvme scan
part list nvme 0
part number nvme 0 hassos-kernel0 kernel0
echo ${kernel0}
```

Permanent fix:

```text
CONFIG_USE_PREBOOT=y
CONFIG_PREBOOT="pci enum; nvme scan"
```

## `Can't set block device` while loading the HAOS kernel

First identify the filesystem from Linux:

```bash
blkid /dev/nvme0n1p2
```

On the verified image, `hassos-kernel0` was SquashFS. Enable:

```text
CONFIG_CMD_SQUASHFS=y
CONFIG_FS_SQUASHFS=y
CONFIG_CMD_FS_GENERIC=y
```

## `Error: unknown compression type`

Cause: U-Boot recognized SquashFS but lacked the decompressor used by the image.

The verified HAOS kernel SquashFS used LZO. Enable:

```text
CONFIG_LZO=y
```

## Build fails with `atf-bl31 ... non-functional`

Build with:

```bash
BL31=/usr/lib/arm-trusted-firmware/rk3399/bl31.elf
```

A missing optional `tee-os` warning is acceptable when binman says the image remains functional.

## SPI readback differs after flashing

Do not boot the image. Reduce SPI frequency to 1 MHz:

```ini
param_spinor_max_freq=1000000
```

Erase, write, and verify again. Two independent readbacks must match the source exactly.

## Slot B fails

An initial HAOS image may have an empty `hassos-kernel1`/`hassos-system1`. Slot A must boot first. HAOS updates can populate the alternate slot later.
