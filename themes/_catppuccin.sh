# Shared by themes/catppuccin-*.sh: maps the official palette names (set by
# the flavor file before sourcing this) onto the slots templates/ use.
ACCENTS="rosewater flamingo pink mauve red maroon peach yellow green teal sky sapphire blue lavender"
DEFAULT_ACCENT=mauve

bg=$base  bg_alt=$mantle  bg_dim=$crust
surface=$surface0  surface_alt=$surface1  overlay=$overlay0
fg=$text  fg_dim=$subtext0
cyan=$sapphire  magenta=$mauve  orange=$peach
cursor=$rosewater  cursor_fg=$base  sel_bg=$rosewater  sel_fg=$base

# terminal palette, as in github.com/catppuccin/kitty
if [[ $MODE == light ]]; then
    color0=$subtext1  color8=$subtext0  color7=$surface2  color15=$surface1
else
    color0=$surface1  color8=$surface2  color7=$subtext1  color15=$subtext0
fi
color1=$red    color9=$red    color2=$green  color10=$green
color3=$yellow color11=$yellow color4=$blue  color12=$blue
color5=$pink   color13=$pink  color6=$teal   color14=$teal

PACKAGES="kvantum-theme-catppuccin-git catppuccin-cursors-$VARIANT
    papirus-folders-catppuccin-git catppuccin-sddm-theme-$VARIANT"

theme_assets() {
    KVANTUM_THEME="catppuccin-$VARIANT-$ACCENT"
    CURSOR_THEME="catppuccin-$VARIANT-$ACCENT-cursors"   # ships hyprcursor too
    PAPIRUS_COLOR="cat-$VARIANT-$ACCENT"
    SDDM_THEME="catppuccin-$VARIANT-$ACCENT"
    NVIM_COLORSCHEME="catppuccin-$VARIANT"
    FIREFOX_THEME="$(awk -v k="$VARIANT-$ACCENT" '$1 == k { print $2 }' "$THEME_DIR/_catppuccin-firefox-ids")"
    FIREFOX_THEME_URL="https://github.com/catppuccin/firefox/releases/download/old/catppuccin_${VARIANT}_${ACCENT}.xpi"
    case "$VARIANT" in   # Chrome Web Store, from github.com/catppuccin/chrome
        latte)     CHROMIUM_THEME=jhjnalhegpceacdhbplhnakmkdliaddd ;;
        frappe)    CHROMIUM_THEME=olhelnoplefjdmncknfphenjclimckaf ;;
        macchiato) CHROMIUM_THEME=cmpdlhmnmjhihmcfnigoememnffkimlk ;;
        mocha)     CHROMIUM_THEME=bkkmolkhemgaeaeggcmfbghljjjoofoh ;;
    esac
    case "$ACCENT" in    # nearest of GNOME's accent colours (libadwaita)
        rosewater|flamingo|pink) GNOME_ACCENT=pink ;;
        mauve|lavender)          GNOME_ACCENT=purple ;;
        red|maroon)              GNOME_ACCENT=red ;;
        peach)                   GNOME_ACCENT=orange ;;
        yellow)                  GNOME_ACCENT=yellow ;;
        green)                   GNOME_ACCENT=green ;;
        teal)                    GNOME_ACCENT=teal ;;
        sky|sapphire|blue)       GNOME_ACCENT=blue ;;
    esac
}

# the same files the AUR packages install, from the upstream releases
theme_fetch() {
    theme_fetch_archive "https://github.com/catppuccin/cursors/releases/download/v2.0.0/$CURSOR_THEME.zip" \
        "$THEME_DATA/icons" "$CURSOR_THEME"
    local kv="$HOME/.config/Kvantum/$KVANTUM_THEME" f
    for f in kvconfig svg; do
        [[ -f "$kv/$KVANTUM_THEME.$f" ]] && continue
        curl -fsSL --retry 3 --retry-all-errors --create-dirs -o "$kv/$KVANTUM_THEME.$f" \
            "https://raw.githubusercontent.com/catppuccin/kvantum/main/themes/$KVANTUM_THEME/$KVANTUM_THEME.$f" &&
            log "theme: installed $kv/$KVANTUM_THEME.$f" ||
            log "theme: could not download the Kvantum $f (the next run tries again)"
    done
}
