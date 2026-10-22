# themes/_style.sh — the look shared by every theme: glass + darkness.
# Tune here, then ./theme-apply (or ./theme-switch) to re-render.
# Sourced by _lib.sh's theme_load after the palette, so $MODE is known.
#
# Values are the most see-through that still keep text readable (WCAG 4.5:1
# for text, 3:1 for dim UI text) over the brightest neon of the wallpaper.
# Lower them and the dimmer colours (inactive workspaces, tmux tabs) go first.

if [[ $MODE == dark ]]; then
    DARKEN=30           # % mix of the background slots toward black
    DEEPEN=0            # % mix of dim text + status colours toward black
    GLASS=85            # % opacity of panels: waybar, wofi, dunst, hyprlock field
    TERM_OPACITY=0.88   # kitty background only — its text stays solid
    WIN_ACTIVE=0.95     # Hyprland opacity of the focused window
    WIN_INACTIVE=0.88   #   … and of the others
else
    # Latte/Dawn are low-contrast even when solid; light glass over this dark
    # wallpaper turns them grey, so stay nearly opaque, skip darkening and
    # deepen dim text + status colours until they pass again
    DARKEN=0
    DEEPEN=25
    GLASS=95
    TERM_OPACITY=0.95
    WIN_ACTIVE=0.97
    WIN_INACTIVE=0.92
fi
