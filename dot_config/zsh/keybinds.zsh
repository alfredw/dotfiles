bindkey -v

# Default is 40 (0.4s), which makes ESC feel laggy on the way to normal mode.
KEYTIMEOUT=1

# Arrow keys search history by what's already typed, rather than walking it
# blindly. Bound in the main keymap, which `bindkey -v` points at viins.
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# ctrl+space accepts the autosuggestion.
bindkey '^ ' autosuggest-accept

# zsh's vi mode refuses to backspace past the point where insert mode started.
# These restore the behaviour every other editor has.
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char

# `v` in normal mode opens the current command line in $EDITOR (nvim).
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# Keep incremental search reachable from normal mode.
bindkey -M vicmd '/' history-incremental-search-backward
bindkey -M vicmd '?' history-incremental-search-forward
