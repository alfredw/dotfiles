alias ls='eza --group-directories-first --icons=auto'
alias ll='eza -lbF --git --group-directories-first --icons=auto'
alias la='eza -labF --git --group-directories-first --icons=auto'
alias lt='eza --tree --level=2 --icons=auto'
alias llt='eza -lbF --git --tree --level=2 --icons=auto'

alias cat='bat --paging=never'
alias less='bat'
export BAT_THEME="Catppuccin Mocha"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview "bat --color=always --style=numbers --line-range=:500 {}"'

alias cd='z'
alias cdi='zi'

alias g='git'
alias gst='git status'
alias gd='git diff'
alias gco='git checkout'
alias gcm='git commit -m'
alias gp='git push'
alias gl='git pull'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
