#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 BUILD_DIR" >&2
  exit 2
fi

BUILD_DIR=$(realpath "$1")
CONFIG="$BUILD_DIR/.config"
SOURCE_DIR=$(cd "$(dirname "$0")/.." && pwd)

if [[ ! -f "$CONFIG" ]]; then
  echo "Missing U-Boot config: $CONFIG" >&2
  echo "Run the board defconfig first." >&2
  exit 1
fi

UBOOT_SOURCE=$(pwd)
if [[ ! -x "$UBOOT_SOURCE/scripts/config" ]]; then
  echo "Run this script from the U-Boot source directory." >&2
  exit 1
fi

scripts/config --file "$CONFIG" --enable CMD_FILEENV
scripts/config --file "$CONFIG" --enable CMD_SETEXPR
scripts/config --file "$CONFIG" --enable CMD_SQUASHFS
scripts/config --file "$CONFIG" --enable CMD_FS_GENERIC
scripts/config --file "$CONFIG" --enable LZO
scripts/config --file "$CONFIG" --enable USE_PREBOOT
scripts/config --file "$CONFIG" --set-str PREBOOT "pci enum; nvme scan"

make O="$BUILD_DIR" olddefconfig

grep -E \
'^CONFIG_CMD_FILEENV=|^CONFIG_CMD_SETEXPR=|^CONFIG_CMD_SQUASHFS=|^CONFIG_FS_SQUASHFS=|^CONFIG_LZO=|^CONFIG_CMD_FS_GENERIC=|^CONFIG_USE_PREBOOT=|^CONFIG_PREBOOT=' \
  "$CONFIG"
