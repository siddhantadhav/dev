# Shared by themes/rose-pine-*.sh: maps the official palette names (set by
# the variant file before sourcing this) onto the slots templates/ use.
ACCENTS="love gold rose pine foam iris"
DEFAULT_ACCENT=iris

# rose-pine's own `surface`/`overlay` names clash with slot names; keep them
rp_surface=$surface  rp_overlay=$overlay

bg=$base  bg_alt=$rp_surface  bg_dim=$nc
surface=$rp_overlay  surface_alt=$highlight_med  overlay=$muted
fg=$text  fg_dim=$subtle
red=$love  green=$pine  yellow=$gold  blue=$foam
cyan=$foam  magenta=$iris  orange=$rose
cursor=$highlight_high  cursor_fg=$text  sel_bg=$highlight_med  sel_fg=$text

# terminal palette, as rose-pine/neovim sets terminal_color_*
color0=$rp_overlay  color8=$subtle  color7=$text  color15=$text
color1=$love  color9=$love   color2=$pine  color10=$pine
color3=$gold  color11=$gold  color4=$foam  color12=$foam
color5=$iris  color13=$iris  color6=$rose  color14=$rose

# no Kvantum, SDDM or Papirus-folder ports → theme_load's neutral fallbacks;
# no official Firefox theme either (AMO only has unofficial uploads)
# rose-pine-gtk-theme-full is for its icons (GTK itself is adw-gtk3, _lib.sh)
PACKAGES="rose-pine-gtk-theme-full rose-pine-cursor"

theme_assets() {
    local v=""
    [[ $VARIANT != main ]] && v="-$VARIANT"
    ICON_THEME="rose-pine$v-icons"
    # the cursor port has no Moon build; Moon uses the main one
    CURSOR_THEME=$([[ $VARIANT == dawn ]] && echo BreezeX-RosePineDawn-Linux || echo BreezeX-RosePine-Linux)
    NVIM_COLORSCHEME="rose-pine-$VARIANT"
    case "$VARIANT" in   # Chrome Web Store, from github.com/rose-pine/google-chrome
        main) CHROMIUM_THEME=noimedcjdohhokijigpfcbjcfcaaahej ;;
        moon) CHROMIUM_THEME=ohjebgkppidheiajbgnnmmieaapjppje ;;
        dawn) CHROMIUM_THEME=faffeempkcpjhcmfpglpkdpbkdmbpaab ;;
    esac
    case "$ACCENT" in    # nearest of GNOME's accent colours (libadwaita)
        love) GNOME_ACCENT=red ;;
        gold) GNOME_ACCENT=yellow ;;
        rose) GNOME_ACCENT=pink ;;
        pine) GNOME_ACCENT=teal ;;
        foam) GNOME_ACCENT=blue ;;
        iris) GNOME_ACCENT=purple ;;
    esac
}

# the same files the AUR packages install, from the upstream releases
theme_fetch() {
    theme_fetch_archive "https://github.com/rose-pine/gtk/releases/download/v2.2.0/$ICON_THEME.tar.gz" \
        "$THEME_DATA/icons" "$ICON_THEME"
    theme_fetch_archive "https://github.com/rose-pine/cursor/releases/download/v1.1.0/$CURSOR_THEME.tar.xz" \
        "$THEME_DATA/icons" "$CURSOR_THEME"
}
