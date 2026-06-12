# dev

Idempotent environment setup, multi-OS (Arch / Debian / macOS), multi-profile (personal / work).

## Fresh machine

```sh
bash <(curl -sSL https://raw.githubusercontent.com/YOURNAME/dev/main/bootstrap)
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
- `configs/` — dotfiles, symlinked into place by `runs/shared/90-symlinks`
- `~/.config/dev/env` — machine-local, sets `DEV_PROFILE` (not tracked)

## Switching profile

```sh
echo 'export DEV_PROFILE=work' > ~/.config/dev/env && ./run
```

## Adding things

- New tool for everyone: script in `runs/shared/`
- OS-specific: `runs/arch/`, `runs/mac/`, `runs/debian/`
- Profile-specific: `runs/profile-work/` or `runs/profile-personal/`
- New OS: add a case to `pkg_install` in `lib.sh` + a `runs/<os>/` dir

Rules: every script must be safe to re-run; never commit work secrets.
