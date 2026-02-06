#!/usr/bin/env bash
set -euo pipefail

TARGET_DESKTOP=${TARGET_BROWSER_DESKTOP:-zen.desktop}
CHECK_INTERVAL=${CHECK_INTERVAL:-30}

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hyde"
STATE_FILE="$STATE_DIR/default-browser-watch.state"
PID_FILE="${XDG_RUNTIME_DIR:-/tmp}/default-browser-watch.pid"

if ! command -v xdg-settings >/dev/null 2>&1 || ! command -v xdg-mime >/dev/null 2>&1; then
  exit 0
fi

mkdir -p "$STATE_DIR"

if [ -f "$PID_FILE" ]; then
  read -r existing_pid < "$PID_FILE" || true
  if [ -n "${existing_pid:-}" ] && kill -0 "$existing_pid" 2>/dev/null; then
    exit 0
  fi
fi

printf '%s' "$$" > "$PID_FILE"
trap 'rm -f "$PID_FILE"' EXIT

notify_mismatch() {
  local details="$1"
  local title="Navegador padrao nao e Zen"
  local body="Esperado: $TARGET_DESKTOP\n$details"

  if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "Hyprland" "$title" "$body"
  elif command -v dunstify >/dev/null 2>&1; then
    dunstify "$title" "$body"
  fi
}

collect_defaults() {
  local settings http https html
  settings="$(xdg-settings get default-web-browser 2>/dev/null || true)"
  http="$(xdg-mime query default x-scheme-handler/http 2>/dev/null || true)"
  https="$(xdg-mime query default x-scheme-handler/https 2>/dev/null || true)"
  html="$(xdg-mime query default text/html 2>/dev/null || true)"
  printf 'settings=%s\nhttp=%s\nhttps=%s\nhtml=%s' "$settings" "$http" "$https" "$html"
}

check_once() {
  local details status prev_status line value
  details="$(collect_defaults)"
  status="ok"

  while IFS= read -r line; do
    value="${line#*=}"
    if [ -n "$value" ] && [ "$value" != "$TARGET_DESKTOP" ]; then
      status="mismatch"
      break
    fi
  done <<< "$details"

  prev_status=""
  if [ -f "$STATE_FILE" ]; then
    read -r prev_status < "$STATE_FILE" || true
  fi

  if [ "$status" = "mismatch" ] && [ "$prev_status" != "mismatch" ]; then
    notify_mismatch "$details"
  fi

  printf '%s\n' "$status" > "$STATE_FILE"
}

watch_inotify() {
  local paths=()
  local path

  for path in \
    "${XDG_CONFIG_HOME:-$HOME/.config}" \
    "${XDG_CONFIG_HOME:-$HOME/.config}/xdg" \
    "${XDG_DATA_HOME:-$HOME/.local/share}/applications" \
    "/etc/xdg" \
    "/usr/share/applications"
  do
    if [ -d "$path" ]; then
      paths+=("$path")
    fi
  done

  if [ "${#paths[@]}" -eq 0 ]; then
    return 1
  fi

  inotifywait -m -q -e close_write,create,delete,move "${paths[@]}" | while read -r _; do
    check_once
  done
}

main() {
  check_once

  if command -v inotifywait >/dev/null 2>&1; then
    watch_inotify || true
  fi

  while true; do
    sleep "$CHECK_INTERVAL"
    check_once
  done
}

main
