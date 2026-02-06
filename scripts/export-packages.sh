#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

pacman -Qqen > "$ROOT_DIR/packages/pacman-explicit.txt"
pacman -Qqem > "$ROOT_DIR/packages/pacman-aur.txt"

if command -v flatpak >/dev/null 2>&1; then
  flatpak list --app --columns=application,branch > "$ROOT_DIR/packages/flatpak.txt"
else
  : > "$ROOT_DIR/packages/flatpak.txt"
fi

if command -v pipx >/dev/null 2>&1; then
  pipx list --short > "$ROOT_DIR/packages/pipx.txt"
else
  : > "$ROOT_DIR/packages/pipx.txt"
fi
