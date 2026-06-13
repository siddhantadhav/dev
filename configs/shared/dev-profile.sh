# dev-profile.sh — sourced by your shell rc. Owns PATH and env, per OS/profile.
[[ -f "$HOME/.config/dev/env" ]] && source "$HOME/.config/dev/env"

addPath() {
    case ":$PATH:" in
        *":$1:"*) ;;                      # already present, skip
        *) export PATH="$1:$PATH" ;;
    esac
}

addPath "$HOME/.local/bin"
addPath "$HOME/.local/scripts"
addPath /usr/local/go/bin
addPath "$HOME/go/bin"
