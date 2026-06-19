# managed by ~/dev — edit there, not here
source "$HOME/.config/dev/profile.sh"

export EDITOR=nvim
alias vim=nvim
alias ls='ls --color=auto'

# --- prompt ----------------------------------------------------------------
# user@host  cwd  git-branch(±dirty)  prompt-char(red on last-cmd failure)
autoload -Uz vcs_info colors && colors
setopt prompt_subst

zstyle ':vcs_info:*'     enable git
zstyle ':vcs_info:*'     check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '*'      # working-tree changes
zstyle ':vcs_info:git:*' stagedstr   '+'      # staged changes
zstyle ':vcs_info:git:*' formats       ' %F{magenta}%b%f%F{yellow}%u%c%f'
zstyle ':vcs_info:git:*' actionformats ' %F{magenta}%b|%a%f%F{yellow}%u%c%f'

# truncate long branch names (e.g. 191-featdb-add-district_zones-…) so the
# prompt stays readable; keeps the head, which usually has the ticket/topic
zstyle ':vcs_info:git*+post-backend:*' hooks trunc-branch
function +vi-trunc-branch() {
    local max=24
    (( ${#hook_com[branch]} > max )) && hook_com[branch]="${hook_com[branch][1,max]}…"
}

# we render venv/conda ourselves below, so stop them munging the prompt
export VIRTUAL_ENV_DISABLE_PROMPT=1

precmd() {
    vcs_info
    # python env indicator: (venv) and/or (conda-env)
    local env=""
    if [[ -n "$VIRTUAL_ENV" ]]; then
        local v=${VIRTUAL_ENV:t}
        # a bare ".venv"/"venv" tells you nothing — show the project dir instead
        [[ "$v" == (.venv|venv|env|.env) ]] && v=${VIRTUAL_ENV:h:t}
        env=$v
    fi
    [[ -n "$CONDA_DEFAULT_ENV" ]] && env="${env:+$env }${CONDA_DEFAULT_ENV}"
    env_info_msg=""
    [[ -n "$env" ]] && env_info_msg="%F{cyan}($env)%f "
}

# (env) [profile] user@host ~/path  branch*   %
PROMPT='${env_info_msg}%F{yellow}[${DEV_PROFILE:-personal}]%f %F{green}%n@%m%f %F{blue}%~%f${vcs_info_msg_0_} %(?.%F{green}.%F{red})%#%f '

# profile-specific secrets (configs/<profile>/.zshrc.secret — git-ignored,
# may not exist on a fresh machine, so source only if present)
dev_root="${DEV_ROOT:-$(cd "$(dirname "$(readlink -f "$HOME/.config/dev/profile.sh")")/../.." && pwd)}"
secret="$dev_root/configs/${DEV_PROFILE:-personal}/.zshrc.secret"
[[ -f "$secret" ]] && source "$secret"
unset dev_root secret


