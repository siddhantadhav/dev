#!/usr/bin/env bash
# lib/core.sh — machine settings, OS/desktop detection, modules and linking.
# Sourced by ./dev; functions are exported to the module scripts it runs.

# machine-local settings (not tracked in git): DEV_PROFILE, DEV_DESKTOP,
# DEV_THEME, DEV_ACCENT
DEV_ENV="$HOME/.config/dev/env"
[[ -f "$DEV_ENV" ]] && source "$DEV_ENV"
export DEV_ROOT="${DEV_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DEV_PROFILE="${DEV_PROFILE:-personal}"
export PKG_DIR="$HOME/pkg"

# --- OS detection ----------------------------------------------------------
# a preset DEV_OS wins, so `DEV_OS=arch ./dev run --dry` previews another OS
if [[ -n "${DEV_OS:-}" ]]; then
    :
elif [[ "$(uname -s)" == Darwin ]]; then
    DEV_OS=macos   # before Homebrew exists, so not by its brew command
elif command -v pacman >/dev/null 2>&1; then
    DEV_OS=arch
elif command -v dnf >/dev/null 2>&1; then
    DEV_OS=fedora
else
    DEV_OS=unknown
fi
export DEV_OS
# Homebrew's prefix, so brew works in the scripts after modules/os/macos
[[ "$DEV_OS" == macos ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# --- desktop -----------------------------------------------------------------
# which modules/desktop/<name> this machine gets: hyprland, gnome or none
# (./dev desktop <name>)
if [[ -z "${DEV_DESKTOP:-}" ]]; then
    case "$DEV_OS" in
        arch)   DEV_DESKTOP=hyprland ;;
        fedora) DEV_DESKTOP=gnome ;;
        *)      DEV_DESKTOP=none ;;
    esac
fi
export DEV_DESKTOP

# --- helpers -----------------------------------------------------------------
log() { printf '\033[1;34m[dev]\033[0m %s\n' "$*"; }

# env_set <NAME> <value> — set one line of ~/.config/dev/env, keeping the others
env_set() {
    mkdir -p "$(dirname "$DEV_ENV")"
    touch "$DEV_ENV"
    { grep -v "^export $1=" "$DEV_ENV" || true; echo "export $1=$2"; } > "$DEV_ENV.tmp"
    mv "$DEV_ENV.tmp" "$DEV_ENV"
    export "$1=$2"
}

# --- modules -----------------------------------------------------------------
# A module is a folder under modules/ with any of:
#   install     run by `dev run`: packages, links, settings (idempotent)
#   templates/  rendered for the current theme into ~/.config/dev/theme/
#   on-theme    run after rendering: links to the rendered files, reloads
# This machine's modules, in order: its OS, its desktop's, the shared ones,
# its profile.
modules() {
    local d
    shopt -s nullglob
    for d in "$DEV_ROOT/modules/os/$DEV_OS" \
             "$DEV_ROOT/modules/desktop/$DEV_DESKTOP"/*/ \
             "$DEV_ROOT/modules/shared"/*/ \
             "$DEV_ROOT/modules/profile/$DEV_PROFILE"; do
        [[ -d "$d" ]] && echo "${d%/}"
    done
}

# module_name <dir> — its path under modules/, e.g. desktop/gnome/shell
module_name() { echo "${1#"$DEV_ROOT/modules/"}"; }

# module_run <dir> <script> — run one of a module's scripts from its folder,
# with $MODULE set so link can take paths relative to it
module_run() {
    [[ -f "$1/$2" ]] || return 0
    log "[$2] $(module_name "$1")"
    ( cd "$1" && MODULE="$1" bash "./$2" )
}

# link <src> <dst> — symlink a module's file into place; <src> is relative to
# the module (or absolute). The repo stays the source of truth.
link() {
    local src="$1" dst="$2"
    [[ "$src" == /* ]] || src="${MODULE:?link: no module}/$src"
    [[ -e "$src" ]] || { log "link: missing source $src"; return 1; }
    [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]] && return 0
    mkdir -p "$(dirname "$dst")"
    # a real file/dir (e.g. an app's default config) would make ln nest the
    # link inside it instead of replacing it — move it aside first
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        local bak="$dst.bak.$(date +%Y%m%d%H%M%S)"
        mv "$dst" "$bak"
        log "backed up $dst -> $bak"
    fi
    ln -sfn "$src" "$dst"
    log "linked $dst -> $src"
}

# fetch_pkg <git url> [name] — clone (or update) a source checkout into ~/pkg
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

export -f log env_set modules module_name module_run link fetch_pkg
