#!/usr/bin/env bash
# lib.sh — shared helpers. Sourced by ./run; functions are exported to scripts.

# machine-local settings (not tracked in git)
[[ -f "$HOME/.config/dev/env" ]] && source "$HOME/.config/dev/env"
export DEV_PROFILE="${DEV_PROFILE:-personal}"
export PKG_DIR="$HOME/pkg"

# --- OS detection ----------------------------------------------------------
if command -v pacman >/dev/null 2>&1; then
    DEV_OS=arch
elif command -v dnf >/dev/null 2>&1; then
    DEV_OS=fedora
else
    DEV_OS=unknown
fi
export DEV_OS

# --- helpers -----------------------------------------------------------------
log() { printf '\033[1;34m[dev]\033[0m %s\n' "$*"; }

# Package names default to Arch's; translate the ones that differ per-OS so
# shared scripts can stay OS-neutral.
pkg_name() {
    local p="$1"
    case "$DEV_OS" in
        fedora) case "$p" in github-cli) p=gh ;; esac ;;
    esac
    printf '%s' "$p"
}

pkg_install() {
    local pkgs=() p
    for p in "$@"; do pkgs+=( "$(pkg_name "$p")" ); done
    case "$DEV_OS" in
        arch)   sudo pacman -S --needed --noconfirm "${pkgs[@]}" ;;
        fedora) sudo dnf install -y "${pkgs[@]}" ;;
        *)      log "pkg_install: unsupported OS '$DEV_OS'"; return 1 ;;
    esac
}

link() {
    local src="$DEV_ROOT/$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
    log "linked $dst -> $src"
}

fetch_pkg() {
    local url="$1"
    local name="${2:-$(basename "$url" .git)}"
    local dst="$PKG_DIR/$name"
    if [[ -d "$dst/.git" ]]; then
        git -C "$dst" pull --ff-only >&2
    else
        mkdir -p "$PKG_DIR"
        git clone "$url" "$dst" >&2
    fi
    echo "$dst"
}

export -f log pkg_name pkg_install link fetch_pkg
