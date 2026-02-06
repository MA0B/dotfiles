#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

TARGET_CONFIG="$ROOT_DIR/config/.config"
TARGET_LOCAL="$ROOT_DIR/local/.local"
TARGET_HOME="$ROOT_DIR/home"

mkdir -p "$TARGET_CONFIG" "$TARGET_LOCAL" "$TARGET_HOME"

CONFIG_DIRS=(
  ambxst
  dunst
  easyeffects
  fastfetch
  gtk-3.0
  gtk-4.0
  hyde
  hypr
  kitty
  Kvantum
  MangoHud
  nwg-look
  qt5ct
  qt6ct
  rofi
  starship
  systemd
  uwsm
  vim
  waybar
  wlogout
)

CONFIG_FILES=(
  baloofilerc
  code-flags.conf
  dolphinrc
  kdeglobals
  mimeapps.list
  spotify-flags.conf
  user-dirs.dirs
  user-dirs.locale
  xdg-terminals.list
)


LOCAL_DIRS=(
  share/applications
  share/fonts
)

HOME_FILES=(
  .bash_profile
  .bashrc
  .gitconfig
  .profile
  .tmux.conf
  .vimrc
  .zprofile
  .zshenv
  .zshrc
)

copy_dir() {
  local src="$1"
  local dst="$2"

  if [ -d "$src" ]; then
    mkdir -p "$dst"
    if command -v rsync >/dev/null 2>&1; then
      rsync -a "$src/" "$dst/"
    else
      cp -a "$src/." "$dst/"
    fi
  fi
}

copy_file() {
  local src="$1"
  local dst="$2"

  if [ -f "$src" ]; then
    mkdir -p "$dst"
    if command -v rsync >/dev/null 2>&1; then
      rsync -a "$src" "$dst/"
    else
      cp -a "$src" "$dst/"
    fi
  fi
}

for dir in "${CONFIG_DIRS[@]}"; do
  copy_dir "$HOME/.config/$dir" "$TARGET_CONFIG/$dir"
done

CODE_USER_DIR="$HOME/.config/Code - OSS/User"
CODE_TARGET_DIR="$TARGET_CONFIG/Code - OSS/User"

copy_file "$CODE_USER_DIR/settings.json" "$CODE_TARGET_DIR"
copy_file "$CODE_USER_DIR/keybindings.json" "$CODE_TARGET_DIR"
copy_file "$CODE_USER_DIR/tasks.json" "$CODE_TARGET_DIR"
copy_file "$CODE_USER_DIR/argv.json" "$CODE_TARGET_DIR"
copy_dir "$CODE_USER_DIR/snippets" "$CODE_TARGET_DIR/snippets"

for file in "${CONFIG_FILES[@]}"; do
  copy_file "$HOME/.config/$file" "$TARGET_CONFIG"
done

for dir in "${LOCAL_DIRS[@]}"; do
  copy_dir "$HOME/.local/$dir" "$TARGET_LOCAL/$dir"
done

for file in "${HOME_FILES[@]}"; do
  copy_file "$HOME/$file" "$TARGET_HOME"
done
