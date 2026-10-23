# dev

Idempotent environment setup, multi-OS (Arch / Debian / macOS), multi-profile (personal / work).

## Fresh machine

```sh
bash <(curl -sSL https://raw.githubusercontent.com/siddhantadhav/dev/main/bootstrap)
```

Installs git, clones this repo to `~/dev`, asks for a profile, runs everything.

## Daily use

```sh
./run            # run everything for this OS + profile
./run zsh        # only scripts matching "zsh"
./run --dry      # preview without executing
```

## Layout

- `run` — executes `runs/<os>/*`, then `runs/shared/*`, then `runs/profile-<profile>/*`
- `lib.sh` — OS/profile detection, `pkg_install`, `link`
- `runs/` — small idempotent scripts, number-prefixed for ordering
- `configs/` — dotfiles, symlinked into place by the run scripts (`runs/shared/98-symlinks`
  and the app's own script)
- `~/.config/dev/env` — machine-local, sets `DEV_PROFILE`, `DEV_THEME`, `DEV_ACCENT`
  (not tracked)

## Switching profile

```sh
./profile-switch work    # changes only DEV_PROFILE in ~/.config/dev/env, re-runs the profile scripts
```

## Desktop (Arch + Hyprland)

Hyprland's config is Lua (`configs/arch/hypr/`); `programs.lua` names the
terminal, file manager, launcher and browser everything else uses.

| Keys | |
|---|---|
| Super + Space | launcher (below) |
| Super + Return / E / B | terminal (kitty) / files (Thunar) / browser (Firefox) |
| Super + Q · V · L | close window · toggle floating · lock |
| Super + 1…0, Shift + 1…0 | go to workspace, move window there |
| Super + S, Shift + S | scratchpad, move window to it |
| Super + drag / right-drag | move / resize; or drag a window's border |

**Launcher** (rofi, `configs/arch/rofi/`): one fuzzy, case-insensitive list of
apps, a Search Google row, clipboard history, files in `~`, ssh hosts and emoji.
Typing `=` first turns it into a calculator (Enter copies the answer,
Shift+Tab goes back to search);
Ctrl+Enter runs the typed text as a command, opens it as a URL, or searches it.

**Bar** (waybar, `configs/arch/waybar/`) — every module is clickable; popups
are floating kitty windows, clicking the module again closes them:

| Module | Click | Right click |
|---|---|---|
| workspaces | go there (scroll: next/previous) | |
| clock · weather | 3-month calendar · 7-day forecast | |
| media (icon + equalizer) | controls window (hover: track, position) | play/pause |
| CPU · GPU · RAM · power | details window | btop |
| volume · brightness | mute · 30/60/100% | mixer (volume) |
| Bluetooth | paired devices, on/off | settings (bluetui) |
| Wi-Fi | networks, password dialog | connection editor |
| battery | details | next power profile |
| ⏻ | lock, suspend, log out, reboot, shut down | |

**Browser**: change `browser`/`browserClass` in `hypr/programs.lua`, then
`./run default-browser` to make it the system default too.

## Firefox userscripts

`configs/shared/userscripts/*.user.js` run in Firefox through Violentmonkey,
which `runs/arch/13-theme-system` force-installs by policy. Firefox only
installs a userscript after you click Install on it, so after the first `./run`:

```sh
./userscript-install                 # opens every script's install page
```

- `media-position` — keeps the song position that waybar's media module shows
  exact; YouTube otherwise clears it on autoplay

## Switching theme

```sh
./theme-switch                          # list themes + accents, show current
./theme-switch catppuccin-latte blue    # theme [accent]
./theme-switch --no-sudo rose-pine-moon # skip SDDM / folder colours / browsers
```

Recolours Hyprland, hyprlock, waybar, rofi, dunst, kitty, tmux, nvim, lazygit,
GTK, Qt (Kvantum), cursor, icons, SDDM and Firefox/Chromium. Running apps reload
live; GTK/Qt apps when reopened, browsers on restart.

- `themes/<family>-<variant>.sh` — palette; `themes/_<family>.sh` maps it onto
  the colour slots and names the family's GTK/Qt/cursor/... packages
- `templates/` — rendered by `theme-apply` into `~/.config/dev/theme/`, which
  the app configs include
- `runs/arch/12-theme-pkgs` installs every theme's packages,
  `13-theme-system` does the sudo parts, `runs/shared/97-theme` the rest
- `themes/_style.sh` — the look for every theme: transparency of panels, the bar
  (`BAR_GLASS`), terminal and windows, how much darker the backgrounds get;
  values are tuned so text stays readable over the wallpaper
- New family: a palette file per variant + a `_<family>.sh`

## Adding things

- New tool for everyone: script in `runs/shared/`
- OS-specific: `runs/arch/`, `runs/mac/`, `runs/debian/`
- Profile-specific: `runs/profile-work/` or `runs/profile-personal/`
- New OS: add a case to `pkg_install` in `lib.sh` + a `runs/<os>/` dir

Rules: every script must be safe to re-run; never commit work secrets.
