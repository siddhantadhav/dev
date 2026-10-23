# dev-profile.sh — sourced by your shell rc. Owns PATH and env, per OS/profile.
[[ -f "$HOME/.config/dev/env" ]] && source "$HOME/.config/dev/env"

addPath() {
    case ":$PATH:" in
        *":$1:"*) ;;                      # already present, skip
        *) export PATH="$1:$PATH" ;;
    esac
}

# macOS: Homebrew (Apple Silicon or Intel prefix)
for brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$brew" ]] && { eval "$("$brew" shellenv)"; break; }
done
unset brew

addPath "$HOME/.local/bin"
addPath "$HOME/.local/scripts"
addPath /usr/local/go/bin
addPath "$HOME/go/bin"

# lazygit: own settings + the colours rendered by ~/dev/theme-apply
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml,$HOME/.config/dev/theme/lazygit.yml"
