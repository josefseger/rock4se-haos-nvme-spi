#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: sudo $0 /path/to/u-boot-rockchip-spi.bin" >&2
  exit 2
fi

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo." >&2
  exit 1
fi

IMAGE=$(realpath "$1")
MTD=${MTD:-/dev/mtd0}
SPI_SIZE=16777216
SIZE=$(stat -c '%s' "$IMAGE")
STAMP=$(date +%Y%m%d-%H%M%S)
OWNER=${SUDO_USER:-root}
HOME_DIR=$(getent passwd "$OWNER" | cut -d: -f6)
BACKUP="$HOME_DIR/spi-backup-$STAMP.bin"
R1=/tmp/spi-readback-1.bin
R2=/tmp/spi-readback-2.bin

[[ -c "$MTD" ]] || { echo "MTD device not found: $MTD" >&2; exit 1; }
(( SIZE > 0 && SIZE <= SPI_SIZE )) || { echo "Unexpected image size: $SIZE" >&2; exit 1; }

command -v flash_erase >/dev/null
command -v mtd_debug >/dev/null

echo "Image: $IMAGE"
echo "Image size: $SIZE bytes"
sha256sum "$IMAGE"

echo "Backing up complete SPI to $BACKUP"
mtd_debug read "$MTD" 0 "$SPI_SIZE" "$BACKUP"
chown "$OWNER":"$OWNER" "$BACKUP" || true
[[ $(stat -c '%s' "$BACKUP") -eq $SPI_SIZE ]]

echo "Erasing complete SPI..."
flash_erase "$MTD" 0 0

echo "Writing image..."
mtd_debug write "$MTD" 0 "$SIZE" "$IMAGE"

echo "Reading back twice..."
rm -f "$R1" "$R2"
mtd_debug read "$MTD" 0 "$SIZE" "$R1"
mtd_debug read "$MTD" 0 "$SIZE" "$R2"

sha256sum "$IMAGE" "$R1" "$R2"
cmp "$IMAGE" "$R1"
cmp "$IMAGE" "$R2"
cmp "$R1" "$R2"

echo "SUCCESS: source and both SPI readbacks are byte-identical."
echo "Backup: $BACKUP"
