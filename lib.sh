#!/usr/bin/env bash
# lib.sh — shared helpers. Sourced by ./run; functions are exported to scripts.

# machine-local settings (not tracked in git)
[[ -f "$HOME/.config/dev/env" ]] && source "$HOME/.config/dev/env"
export DEV_ROOT="${DEV_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
export DEV_PROFILE="${DEV_PROFILE:-personal}"
export PKG_DIR="$HOME/pkg"

# --- OS detection ----------------------------------------------------------
# a preset DEV_OS wins, so `DEV_OS=arch ./run --dry` previews another OS
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
# Homebrew's prefix, so brew works in the scripts after runs/macos/00-homebrew
[[ "$DEV_OS" == macos ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# --- desktop -----------------------------------------------------------------
# which runs/desktop-<name> this machine gets: hyprland, gnome or none. Set
# DEV_DESKTOP in ~/.config/dev/env (./desktop-switch) to pick another.
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

# --- packages ------------------------------------------------------------------
# $DEV_ROOT/packages names each app once, with its package(s) on every OS;
# scripts install by that name, so the same app list works everywhere.

# pkg_resolve <name> — this OS's package specs for <name>, one per line;
# nothing when the app isn't available here ("-"). Unlisted names pass through.
pkg_resolve() {
    local name="$1" col spec
    case "$DEV_OS" in
        arch)   col=2 ;;
        fedora) col=3 ;;
        macos)  col=4 ;;
        *)      echo "$name"; return 0 ;;
    esac
    spec="$(awk -v n="$name" -v c="$col" '$1 !~ /^#/ && $1 == n { print $c; exit }' "$DEV_ROOT/packages")"
    [[ -n "$spec" ]] || spec="$name"
    [[ "$spec" == - ]] && return 0
    tr ',' '\n' <<< "$spec"
}

# pkg_installed <package> [cask] — without sudo, so re-runs don't prompt
pkg_installed() {
    case "$DEV_OS" in
        arch)   pacman -Qq "$1" >/dev/null 2>&1 ;;
        fedora) rpm -q --whatprovides "$1" >/dev/null 2>&1 ;;
        macos)  brew list "--${2:-formula}" "$1" >/dev/null 2>&1 ;;
        *)      return 1 ;;
    esac
}

# pkg_copr <owner>/<project> — enable a Fedora COPR once
pkg_copr() {
    dnf copr list --enabled 2>/dev/null | grep -qx "copr.fedorainfracloud.org/$1" && return 0
    sudo dnf copr enable -y "$1"
}

# pkg_github <owner>/<repo>:<asset> — a release binary into ~/.local/bin, named
# after the repo; {arch} in the asset becomes x86_64 / aarch64
pkg_github() {
    local repo="${1%%:*}" asset="${1#*:}" bin
    bin="$HOME/.local/bin/${repo##*/}"
    command -v "${repo##*/}" >/dev/null 2>&1 || [[ -x "$bin" ]] && return 0
    asset="${asset//\{arch\}/$(uname -m)}"
    mkdir -p "$HOME/.local/bin"
    curl -fsSL --retry 3 --retry-all-errors "https://github.com/$repo/releases/latest/download/$asset" -o "$bin.tmp"
    chmod 755 "$bin.tmp" && mv "$bin.tmp" "$bin"
    log "installed $bin (github.com/$repo)"
}

pkg_install() {
    local name spec copr pkgs=() aur=() casks=()
    for name in "$@"; do
        local specs
        specs="$(pkg_resolve "$name")"
        if [[ -z "$specs" ]]; then
            log "$name: no $DEV_OS package, skipped"
            continue
        fi
        while read -r spec; do
            case "$spec" in
                github:*) pkg_github "${spec#github:}" ;;
                aur:*)    pkg_installed "${spec#aur:}" || aur+=( "${spec#aur:}" ) ;;
                cask:*)   pkg_installed "${spec#cask:}" cask || casks+=( "${spec#cask:}" ) ;;
                copr:*)
                    copr="${spec#copr:}"
                    if ! pkg_installed "${copr#*:}"; then
                        pkg_copr "${copr%%:*}"
                        pkgs+=( "${copr#*:}" )
                    fi
                    ;;
                *)        pkg_installed "$spec" || pkgs+=( "$spec" ) ;;
            esac
        done <<< "$specs"
    done
    (( ${#pkgs[@]} + ${#aur[@]} + ${#casks[@]} )) || return 0
    case "$DEV_OS" in
        arch)
            (( ${#pkgs[@]} )) && sudo pacman -S --needed --noconfirm "${pkgs[@]}"
            (( ${#aur[@]} ))  && yay -S --needed --noconfirm "${aur[@]}"
            ;;
        fedora) sudo dnf install -y "${pkgs[@]}" ;;
        macos)
            (( ${#pkgs[@]} ))  && brew install "${pkgs[@]}"
            (( ${#casks[@]} )) && brew install --cask "${casks[@]}"
            ;;
        *)      log "pkg_install: unsupported OS '$DEV_OS'"; return 1 ;;
    esac
    return 0
}

pkg_uninstall() {
    local name spec pkgs=()
    for name in "$@"; do
        while read -r spec; do
            spec="${spec#*:}"; spec="${spec#*:}"   # drop aur:/cask:/copr:<repo>:
            [[ -n "$spec" ]] && pkg_installed "$spec" && pkgs+=( "$spec" )
        done <<< "$(pkg_resolve "$name")"
    done
    (( ${#pkgs[@]} )) || return 0
    case "$DEV_OS" in
        arch)   sudo pacman -Rns --noconfirm "${pkgs[@]}" ;;
        fedora) sudo dnf remove -y "${pkgs[@]}" ;;
        macos)  brew uninstall "${pkgs[@]}" ;;
        *)      log "pkg_uninstall: unsupported OS '$DEV_OS'"; return 1 ;;
    esac
}

link() {
    local src="$DEV_ROOT/$1" dst="$2"
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

export -f log pkg_resolve pkg_installed pkg_copr pkg_github pkg_install pkg_uninstall link fetch_pkg
