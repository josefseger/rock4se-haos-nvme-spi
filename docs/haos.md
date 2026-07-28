# Prepare HAOS on NVMe and boot

## Flash HAOS to NVMe

Flash the HAOS image intended for the ROCK 4 family directly to the entire NVMe device. Confirm the exact target device before writing; this destroys all data on that target.

After flashing, the GPT layout should include partitions resembling:

```text
hassos-boot
hassos-kernel0
hassos-system0
hassos-kernel1
hassos-system1
hassos-bootstate
hassos-overlay
hassos-data
```

On the tested initial image:

- `hassos-kernel0` contained a SquashFS filesystem with `/Image`.
- `hassos-kernel1` was initially empty.
- `hassos-system0` used EROFS.

## First boot

1. Shut down Armbian cleanly.
2. Disconnect power.
3. Remove the SD card.
4. Leave the NVMe installed.
5. Connect UART.
6. Apply power and do not interrupt autoboot.

The successful sequence includes:

```text
Trying to boot from SPI
...
Scanning bootdev 'nvme#0...'
Boot script loaded from nvme
...
Trying to boot slot A ... Loading kernel ...
29706752 bytes read
Starting kernel ...
Linux version ...-haos
Machine model: Radxa ROCK 4SE
```

The first HAOS boot can take several minutes while the data filesystem is expanded and services initialize.
