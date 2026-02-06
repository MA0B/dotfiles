# dotfiles

Arch Linux + Hyprland/HyDE/Ambxst setup. This repo is stow-ready and includes
package lists for a minimal restore.

## Layout
- `config/.config/...` -> `~/.config/...`
- `local/.local/...` -> `~/.local/...`
- `home/` -> `~/` dotfiles

## Restore (fresh Arch)
1. Install prerequisites:
   - `sudo pacman -S --needed git stow base-devel`
2. Clone the repo:
   - `git clone git@github.com:<you>/dotfiles.git ~/dotfiles`
3. Install packages and link configs:
   - `~/dotfiles/scripts/bootstrap.sh`

## Update from current system
Run:
- `~/dotfiles/scripts/collect.sh`
- `~/dotfiles/scripts/export-packages.sh`

## Notes
- `scripts/collect.sh` copies a curated set of configs. Edit the list if you
  want to include more.
- Caches and sensitive app data are intentionally not tracked.
