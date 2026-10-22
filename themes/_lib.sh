# themes/_lib.sh — load a theme palette. Sourced by theme-apply, theme-switch
# and runs/arch/12-theme-pkgs / 13-theme-system.
#
# A theme is themes/<family>-<variant>.sh: it sets the official palette names,
# then sources themes/_<family>.sh, which maps them onto the slots below and
# defines theme_assets() (package-provided GTK/Qt/cursor/... names).

THEME_DIR="${DEV_ROOT:?}/themes"
DEV_THEME_DEFAULT=catppuccin-mocha

# colour slots every template may use; each also gets a <slot>_raw without '#'
THEME_SLOTS="bg bg_alt bg_dim surface surface_alt overlay fg fg_dim
    red green yellow blue cyan magenta orange accent
    cursor cursor_fg sel_bg sel_fg
    color0 color1 color2 color3 color4 color5 color6 color7
    color8 color9 color10 color11 color12 color13 color14 color15"
THEME_NAMES="MODE FAMILY VARIANT ACCENT GTK_THEME GTK_PREFER_DARK ICON_THEME
    CURSOR_THEME KVANTUM_THEME NVIM_COLORSCHEME"

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
    . "$THEME_DIR/$name.sh"

    ACCENT="${2:-$DEFAULT_ACCENT}"
    [[ " $ACCENTS " == *" $ACCENT "* ]] || { echo "accent '$ACCENT' not in $name (have: $ACCENTS)" >&2; return 1; }
    accent="${!ACCENT}"

    theme_assets

    # neutral fallbacks where the family has no port
    local dark=$([[ $MODE == dark ]] && echo 1 || echo 0)
    GTK_PREFER_DARK=$dark
    : "${GTK_THEME:=Adwaita}"
    : "${CURSOR_THEME:=Adwaita}"
    : "${ICON_THEME:=$( ((dark)) && echo Papirus-Dark || echo Papirus)}"
    : "${KVANTUM_THEME:=$( ((dark)) && echo KvGnomeDark || echo KvGnome)}"
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
