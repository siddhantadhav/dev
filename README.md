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
./dev run                 # set up everything for this OS + desktop + profile
./dev run tmux            # only the modules whose path matches "tmux"
./dev run --dry           # list the modules without running them
./dev theme               # list themes + accents, show the current one
./dev desktop hyprland    # switch this machine's desktop (hyprland / gnome / none)
./dev profile work        # switch this machine's profile (personal / work)
```

`DEV_OS=arch DEV_DESKTOP=hyprland ./dev run --dry` previews another machine.

## Layout

Everything about one app lives in one folder, a **module**:

```
dev                  the command above
bootstrap            fresh machine -> ./dev run
packages             every app once, with its package on Arch, Fedora and macOS
lib/                 core.sh (detection, modules, link), pkg.sh (pkg_install), theme.sh
themes/              <family>/<variant>.sh palettes, <family>/family.sh, style.sh
modules/
  os/<os>/                 package-manager prep: yay, the docker-ce repo, Homebrew
  desktop/<desktop>/<app>/ hyprland: hyprland dunst network rofi thunar waybar
                           gnome: shell keys desktop
  shared/<app>/            every OS: appearance browsers docker fonts git go
                           kitty lazygit nvim tmux zsh
  profile/<profile>/       personal / work: git identity, profile-only tools
```

A module folder can have:

- `install` — run by `./dev run`: packages (`pkg_install <name>`, names from
  `packages`), links (`link <file in the module> <destination>`), settings.
  Must be safe to re-run.
- `templates/` — rendered for the current theme into `~/.config/dev/theme/`
  (same file names), which the app's config includes
- `on-theme` — run after rendering: links to the rendered files, live reload
- the app's config files, or `config/` when the whole folder is linked

`./dev run` runs the `install`s in order (the OS, the desktop's modules, the
shared ones, the profile), then applies the theme. `~/.config/dev/env` (not
tracked) holds `DEV_PROFILE`, `DEV_DESKTOP`, `DEV_THEME`, `DEV_ACCENT`;
`DEV_DESKTOP` defaults to `hyprland` on Arch, `gnome` on Fedora, `none` on macOS.

## Desktop: Hyprland (any Linux)

Arch packages it; Fedora gets it from the `sdegler/hyprland` COPR (same
versions). On Fedora, rofi-emoji isn't packaged, so the launcher has no emoji
list, and the bar's power-profile switching needs `powerprofilesctl`, which
Fedora's `tuned-ppd` doesn't ship.

Hyprland's config is Lua (`modules/desktop/hyprland/hyprland/config/`); `programs.lua` names the
terminal, file manager, launcher and browser everything else uses.

| Keys | |
|---|---|
| Super + Space | launcher (below) |
| Super + Return / E / B | terminal (kitty) / files (Thunar) / browser (Firefox) |
| Super + Q · V · L | close window · toggle floating · lock |
| Super + 1…0, Shift + 1…0 | go to workspace, move window there |
| Super + S, Shift + S | scratchpad, move window to it |
| Super + drag / right-drag | move / resize; or drag a window's border |

**Launcher** (rofi, `modules/desktop/hyprland/rofi/`): one fuzzy, case-insensitive list of
apps, a Search Google row, clipboard history, files in `~`, ssh hosts and emoji.
Typing `=` first turns it into a calculator (Enter copies the answer,
Shift+Tab goes back to search);
Ctrl+Enter runs the typed text as a command, opens it as a URL, or searches it.

**Bar** (waybar, `modules/desktop/hyprland/waybar/`) — every module is clickable; popups
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

**Browser**: change `browser`/`browserClass` in `programs.lua`, then
`./dev run browsers` to make it the system default too (on any Linux desktop).

## Desktop: GNOME

GNOME keeps working like GNOME, in the theme's colours:

- `shell` — the extensions, which it owns: User Themes, AppIndicator, Just
  Perfection (faster animations, no workspace popup) and Blur my Shell (glass
  top bar, blurred overview). Anything enabled by hand is turned off on the
  next run; add it to the list in `shell/install` to keep it. The shell's theme
  is GNOME's own stylesheet recoloured (`shell/recolor`), so it always matches
  the installed GNOME version.
- `keys` — the basics shared with Hyprland: Super + Return / Q / B / E / L,
  Super + 1…0 (Shift: move the window), Super + Space for search, Super +
  drag / right-drag; Alt+Tab switches windows
- `desktop` — the shared wallpaper, monospace font, touchpad, Qt through Kvantum

## Firefox userscripts

`modules/shared/browsers/userscripts/*.user.js` run in Firefox through
Violentmonkey, which `browsers/on-theme` force-installs by policy. Firefox only
installs a userscript after you click Install on it, so after the first `./dev run`:

```sh
./dev userscripts                    # opens every script's install page
```

- `media-position` — keeps the song position that waybar's media module shows
  exact; YouTube otherwise clears it on autoplay

## Switching theme

```sh
./dev theme                              # list themes + accents, show current
./dev theme catppuccin-latte blue        # theme [accent]
./dev theme --no-sudo rose-pine-moon     # skip SDDM / folder colours / browsers
./dev theme apply                        # re-apply the current one (after editing a template)
```

Recolours, on every OS: kitty, tmux, nvim, lazygit, Firefox (and Chromium on
Linux). On Linux also GTK (adw-gtk3 + libadwaita recoloured), Qt (Kvantum),
cursor, icons, Flatpak apps and SDDM; Hyprland, hyprlock, waybar, rofi and
dunst on Hyprland; the shell on GNOME. Running apps reload live; GTK/Qt/Flatpak
apps when reopened, browsers on restart. Electron apps only follow dark/light
(Teams for Linux is told to); GNOME's login screen keeps its own look.

- `themes/<family>/<variant>.sh` — palette; `themes/<family>/family.sh` maps it
  onto the colour slots and names the family's Qt/cursor/icon/... packages
- `modules/shared/appearance` — installs every theme's packages on Arch; on
  Fedora its `on-theme` downloads the current theme's files from upstream into
  `~/.local/share` (`theme_fetch` in `family.sh`)
- `themes/style.sh` — the look for every theme: transparency of panels, the bar
  (`BAR_GLASS`), terminal and windows, how much darker the backgrounds get;
  values are tuned so text stays readable over the wallpaper
- New family: `themes/<family>/` with a palette file per variant + `family.sh`

## Adding things

- New app: a line in `packages` (its name on each OS), then a module folder
  with an `install` — `modules/shared/<app>/` for every machine,
  `modules/desktop/<desktop>/<app>/` for one desktop,
  `modules/profile/<profile>/install` for one profile
- Themed app: its template in the module's `templates/`, reload in `on-theme`
- New OS: a column in `packages`, a case in `lib/core.sh` (detection) and
  `lib/pkg.sh` (`pkg_resolve`, `pkg_installed`, `pkg_install`) + `modules/os/<os>/`
- New desktop: `modules/desktop/<name>/`

Rules: every script must be safe to re-run; never commit work secrets.
