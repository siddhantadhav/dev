# dev

Idempotent environment setup: the same apps, dotfiles and theme on Arch, Fedora
and macOS, with a desktop (Hyprland / GNOME) and a profile (personal / work)
chosen per machine.

## Fresh machine

```sh
bash <(curl -sSL https://raw.githubusercontent.com/siddhantadhav/dev/main/bootstrap)
```

Installs git (and Homebrew on macOS), clones this repo to `~/dev`, asks for a
profile and, on Linux, a desktop, then runs everything.

## Daily use

```sh
./run            # run everything for this OS + desktop + profile
./run zsh        # only scripts matching "zsh"
./run --dry      # preview without executing
```

## Layout

- `run` — executes `runs/<os>/*`, then `runs/desktop-<desktop>/*`, then
  `runs/shared/*`, then `runs/profile-<profile>/*`
- `packages` — every app once, with its package name on Arch, Fedora and macOS
  (`-` where there's none; `aur:`, `copr:`, `cask:`, `github:` for other sources)
- `lib.sh` — OS/desktop/profile detection, `pkg_install <name>…` (looks names up
  in `packages`, skips what's installed), `link`
- `runs/<os>/` — only package-manager prep: yay (Arch), the docker-ce repo
  (Fedora), Homebrew (macOS)
- `runs/desktop-hyprland/`, `runs/desktop-gnome/` — the desktop and its tools
- `runs/shared/` — everything else, on every OS: shell, editor, git tools, Go,
  Docker, kitty, Firefox, Chromium, fonts, theme
- `runs/` scripts are small and idempotent, number-prefixed for ordering
- `configs/` — dotfiles, symlinked into place by the run scripts (`runs/shared/98-symlinks`
  and the app's own script)
- `~/.config/dev/env` — machine-local, sets `DEV_PROFILE`, `DEV_DESKTOP`,
  `DEV_THEME`, `DEV_ACCENT` (not tracked). `DEV_DESKTOP` defaults to `hyprland` on
  Arch, `gnome` on Fedora, `none` on macOS
- `DEV_OS=arch ./run --dry` previews another OS's run

## Switching profile or desktop

```sh
./profile-switch work    # changes only DEV_PROFILE in ~/.config/dev/env, re-runs the profile scripts
./desktop-switch hyprland  # changes only DEV_DESKTOP, installs that desktop, re-applies the theme
```

## Desktop: Hyprland (any Linux)

Arch packages it; Fedora gets it from the `sdegler/hyprland` COPR (same
versions). On Fedora, rofi-emoji isn't packaged, so the launcher has no emoji
list, and the bar's power-profile switching needs `powerprofilesctl`, which
Fedora's `tuned-ppd` doesn't ship.

Hyprland's config is Lua (`configs/hyprland/hypr/`); `programs.lua` names the
terminal, file manager, launcher and browser everything else uses.

| Keys | |
|---|---|
| Super + Space | launcher (below) |
| Super + Return / E / B | terminal (kitty) / files (Thunar) / browser (Firefox) |
| Super + Q · V · L | close window · toggle floating · lock |
| Super + 1…0, Shift + 1…0 | go to workspace, move window there |
| Super + S, Shift + S | scratchpad, move window to it |
| Super + drag / right-drag | move / resize; or drag a window's border |

**Launcher** (rofi, `configs/hyprland/rofi/`): one fuzzy, case-insensitive list of
apps, a Search Google row, clipboard history, files in `~`, ssh hosts and emoji.
Typing `=` first turns it into a calculator (Enter copies the answer,
Shift+Tab goes back to search);
Ctrl+Enter runs the typed text as a command, opens it as a URL, or searches it.

**Bar** (waybar, `configs/hyprland/waybar/`) — every module is clickable; popups
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
`./run default-browser` to make it the system default too (on any Linux desktop).

## Desktop: GNOME

GNOME stays as it is; `runs/desktop-gnome` adds Kvantum for Qt apps and the User
Themes extension, so the theme also reaches the top bar, overview and
notifications.

## Firefox userscripts

`configs/shared/userscripts/*.user.js` run in Firefox through Violentmonkey,
which `runs/shared/13-theme-system` force-installs by policy. Firefox only
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

Recolours, on every OS: kitty, tmux, nvim, lazygit, Firefox (and Chromium on
Linux). On Linux also GTK, Qt (Kvantum), cursor, icons, Flatpak apps; Hyprland,
hyprlock, waybar, rofi, dunst and SDDM on Hyprland; the shell and accent colour
on GNOME. Running apps reload live; GTK/Qt/Flatpak apps when reopened, browsers
on restart. Electron apps only follow dark/light (Teams for Linux is told to);
GNOME's login screen keeps its own look.

- `themes/<family>-<variant>.sh` — palette; `themes/_<family>.sh` maps it onto
  the colour slots and names the family's GTK/Qt/cursor/... packages
- `templates/` — rendered by `theme-apply` into `~/.config/dev/theme/`, which
  the app configs include
- `runs/shared/12-theme-pkgs` installs every theme's packages on Arch, and on
  Fedora downloads the current theme's files from upstream into `~/.local/share`
  (`theme_fetch` in `themes/_<family>.sh`); `runs/shared/13-theme-system` does the
  sudo parts, `runs/shared/97-theme` the rest
- `themes/_style.sh` — the look for every theme: transparency of panels, the bar
  (`BAR_GLASS`), terminal and windows, how much darker the backgrounds get;
  values are tuned so text stays readable over the wallpaper
- New family: a palette file per variant + a `_<family>.sh`

## Adding things

- New app for everyone: a line in `packages` (its name on each OS), then
  `pkg_install <name>` from a script in `runs/shared/`
- Desktop-specific: `runs/desktop-<desktop>/`
- OS prep (package managers, repos): `runs/arch/`, `runs/fedora/`, `runs/macos/`
- Profile-specific: `runs/profile-work/` or `runs/profile-personal/`
- New OS: a column in `packages`, a case in `lib.sh` (detection, `pkg_resolve`,
  `pkg_installed`, `pkg_install`) + a `runs/<os>/` dir

Rules: every script must be safe to re-run; never commit work secrets.
