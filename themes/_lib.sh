# themes/_lib.sh — load a theme palette. Sourced by theme-apply, theme-switch
# and runs/shared/12-theme-pkgs / 13-theme-system.
#
# A theme is themes/<family>-<variant>.sh: it sets the official palette names,
# then sources themes/_<family>.sh, which maps them onto the slots below and
# defines theme_assets() (package-provided Qt/cursor/icon/... names) and
# theme_fetch() (the same files from upstream, where there's no package).

THEME_DIR="${DEV_ROOT:?}/themes"
DEV_THEME_DEFAULT=catppuccin-mocha

# colour slots every template may use; each also gets a <slot>_raw without '#'
THEME_SLOTS="bg bg_alt bg_dim surface surface_alt overlay fg fg_dim
    red green yellow blue cyan magenta orange accent raised
    cursor cursor_fg sel_bg sel_fg
    color0 color1 color2 color3 color4 color5 color6 color7
    color8 color9 color10 color11 color12 color13 color14 color15"
THEME_NAMES="MODE FAMILY VARIANT ACCENT GTK_THEME SHELL_THEME GTK_PREFER_DARK ICON_THEME
    CURSOR_THEME KVANTUM_THEME NVIM_COLORSCHEME GNOME_ACCENT
    GLASS_HEX GLASS_FRAC BAR_GLASS_FRAC TERM_OPACITY WIN_ACTIVE WIN_INACTIVE"
# slots that _style.sh pulls toward black: DARKEN for backgrounds, DEEPEN for
# dim text and status colours (accent and terminal ANSI colours stay official)
THEME_DARKEN_SLOTS="bg bg_alt bg_dim surface surface_alt"
THEME_DEEPEN_SLOTS="fg_dim overlay red green yellow blue cyan magenta orange"

# theme_mix <#rrggbb> <pct> — mix pct% toward black
theme_mix() {
    local hex=${1#\#} pct=$2 i out="#"
    for i in 0 2 4; do
        printf -v out '%s%02x' "$out" $(( 16#${hex:i:2} * (100 - pct) / 100 ))
    done
    echo "$out"
}

theme_list() {
    local f
    for f in "$THEME_DIR"/[!_]*.sh; do basename "$f" .sh; done
}

# theme_load <theme> [accent] — an empty/invalid accent is an error; callers
# that want the default pass nothing.
theme_load() {
    local name="$1"
    [[ -f "$THEME_DIR/$name.sh" ]] || { echo "unknown theme: $name (have: $(theme_list | xargs))" >&2; return 1; }
    # assets are optional per family; clear the previous theme's
    GTK_THEME="" ICON_THEME="" CURSOR_THEME="" KVANTUM_THEME="" NVIM_COLORSCHEME=""
    SDDM_THEME="" PAPIRUS_COLOR="" FIREFOX_THEME="" FIREFOX_THEME_URL="" CHROMIUM_THEME="" PACKAGES=""
    GNOME_ACCENT=""
    . "$THEME_DIR/$name.sh"

    ACCENT="${2:-$DEFAULT_ACCENT}"
    [[ " $ACCENTS " == *" $ACCENT "* ]] || { echo "accent '$ACCENT' not in $name (have: $ACCENTS)" >&2; return 1; }
    accent="${!ACCENT}"

    theme_assets

    # GTK is adw-gtk3 (GTK3) and libadwaita (GTK4) for every family, recoloured
    # by templates/gtk{3,4}.css: no family's own GTK theme keeps up with libadwaita
    local dark=$([[ $MODE == dark ]] && echo 1 || echo 0)
    GTK_PREFER_DARK=$dark
    GTK_THEME=$( ((dark)) && echo adw-gtk3-dark || echo adw-gtk3)
    # GNOME Shell's stylesheet recoloured (themes/gnome-shell-recolor); one
    # name per theme so the User Themes extension reloads when it changes
    SHELL_THEME="dev-$FAMILY-$VARIANT-$ACCENT"

    # neutral fallbacks where the family has no port
    : "${CURSOR_THEME:=Adwaita}"
    : "${ICON_THEME:=$( ((dark)) && echo Papirus-Dark || echo Papirus)}"
    : "${KVANTUM_THEME:=$( ((dark)) && echo KvGnomeDark || echo KvGnome)}"
    : "${GNOME_ACCENT:=blue}"

    . "$THEME_DIR/_style.sh"
    local v
    for v in $THEME_DARKEN_SLOTS; do
        printf -v "$v" '%s' "$(theme_mix "${!v}" "$DARKEN")"
    done
    for v in $THEME_DEEPEN_SLOTS; do
        printf -v "$v" '%s' "$(theme_mix "${!v}" "$DEEPEN")"
    done
    printf -v GLASS_HEX '%02x' $(( GLASS * 255 / 100 ))
    printf -v GLASS_FRAC '0.%02d' "$GLASS"
    printf -v BAR_GLASS_FRAC '0.%02d' "$BAR_GLASS"
    # popovers, dialogs: a step above the window in dark mode; light themes'
    # base is already their lightest colour
    raised=$( ((dark)) && echo "$surface" || echo "$bg")
    return 0
}

# theme_render <template> <output> — substitute only theme variables, so a
# template's own '$'s (hyprlock vars, shell) pass through untouched.
theme_render() {
    local v vars=""
    for v in $THEME_SLOTS; do
        export "$v" "${v}_raw=${!v#\#}"
        vars+=" \${$v} \${${v}_raw}"
    done
    for v in $THEME_NAMES; do export "$v"; vars+=" \${$v}"; done
    envsubst "$vars" < "$1" > "$2.tmp" && mv "$2.tmp" "$2"
}

# --- theme files without packages (Fedora) -------------------------------------
# Arch installs every theme's PACKAGES (runs/shared/12-theme-pkgs); elsewhere
# theme_fetch puts the current theme's files where GTK, Kvantum and the cursor
# also look, per user: ~/.local/share/{themes,icons} and ~/.config/Kvantum.
THEME_DATA="${XDG_DATA_HOME:-$HOME/.local/share}"

# theme_dir <name> — where theme <name> is installed: the user's copy, else the system's
theme_dir() {
    local d
    for d in "$THEME_DATA/themes/$1" "/usr/share/themes/$1"; do
        [[ -d "$d" ]] && { echo "$d"; return 0; }
    done
    return 1
}

# theme_fetch_archive <url> <dest dir> <name>... — unpack a .zip/.tar.* and
# move each named directory (found up to 2 levels deep) into <dest dir>.
# Skips names already there.
theme_fetch_archive() {
    local url="$1" dest="$2" name tmp src missing=()
    shift 2
    for name in "$@"; do
        [[ -d "$dest/$name" ]] || missing+=( "$name" )
    done
    (( ${#missing[@]} )) || return 0
    tmp="$(mktemp -d)"
    if ! curl -fsSL --retry 3 --retry-all-errors "$url" -o "$tmp/archive"; then
        rm -rf "$tmp"
        log "theme: could not download $url (the next run tries again)"
        return 0
    fi
    mkdir -p "$tmp/x" "$dest"
    case "$url" in
        *.zip) unzip -q "$tmp/archive" -d "$tmp/x" ;;
        *)     tar -C "$tmp/x" -xf "$tmp/archive" 2>/dev/null ;;   # macOS tar adds xattr noise
    esac
    for name in "${missing[@]}"; do
        src="$(find "$tmp/x" -mindepth 1 -maxdepth 2 -type d -name "$name" | head -n1)"
        if [[ -n "$src" ]]; then
            rm -rf "${dest:?}/$name"
            mv "$src" "$dest/$name"
            log "theme: installed $dest/$name"
        else
            log "theme: $name not in $url"
        fi
    done
    rm -rf "$tmp"
}
