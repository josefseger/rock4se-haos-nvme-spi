#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 UBOOT_SOURCE_DIR BUILD_DIR" >&2
  exit 2
fi

SRC=$(realpath "$1")
BUILD=$(realpath "$2")
BL31=${BL31:-/usr/lib/arm-trusted-firmware/rk3399/bl31.elf}

[[ -f "$BL31" ]] || { echo "Missing BL31: $BL31" >&2; exit 1; }
[[ -f "$BUILD/.config" ]] || { echo "Missing $BUILD/.config" >&2; exit 1; }

rm -f "$BUILD/u-boot-rockchip-spi.bin" "$BUILD/.binman_stamp"

make -C "$SRC" O="$BUILD" BL31="$BL31" -j"$(nproc)"

IMAGE="$BUILD/u-boot-rockchip-spi.bin"
[[ -f "$IMAGE" ]] || { echo "Build completed but image is missing: $IMAGE" >&2; exit 1; }

ls -lh "$IMAGE"
sha256sum "$IMAGE"
strings "$IMAGE" | grep -Ei 'fileenv|sqfsload|sqfsls|squashfs|lzo|preboot=' || true
