#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v pacman >/dev/null 2>&1; then
  echo "pacman not found. This script targets Arch Linux." >&2
  exit 1
fi

sudo pacman -Syu --needed --noconfirm git stow base-devel

if [ -f "$ROOT_DIR/packages/pacman-explicit.txt" ]; then
  sudo pacman -S --needed --noconfirm - < "$ROOT_DIR/packages/pacman-explicit.txt"
fi

AUR_HELPER=${AUR_HELPER:-yay}

if [ -f "$ROOT_DIR/packages/pacman-aur.txt" ]; then
  if ! command -v "$AUR_HELPER" >/dev/null 2>&1; then
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"
    (cd "$tmpdir/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
    AUR_HELPER=yay
  fi

  "$AUR_HELPER" -S --needed --noconfirm - < "$ROOT_DIR/packages/pacman-aur.txt"
fi

if command -v flatpak >/dev/null 2>&1; then
  if [ -f "$ROOT_DIR/packages/flatpak.txt" ]; then
    awk '{print $1}' "$ROOT_DIR/packages/flatpak.txt" | xargs -r flatpak install -y flathub
  fi
fi

if command -v pipx >/dev/null 2>&1; then
  if [ -f "$ROOT_DIR/packages/pipx.txt" ]; then
    awk '{print $1}' "$ROOT_DIR/packages/pipx.txt" | xargs -r pipx install
  fi
fi

"$ROOT_DIR/scripts/stow.sh"
