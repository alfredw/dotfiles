if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
  FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
fi

autoload -Uz compinit
zcompdump="$XDG_CACHE_HOME/zsh/zcompdump"
mkdir -p "$(dirname $zcompdump)"
if [[ -n $zcompdump(#qNmh-20) ]]; then
  compinit -C -u -d "$zcompdump"
else
  compinit -u -d "$zcompdump"
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:descriptions' format '[%d]'

if [[ -f /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc ]]; then
  source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc
fi
