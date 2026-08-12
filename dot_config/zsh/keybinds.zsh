bindkey -v

# Default is 40 (0.4s), which makes ESC feel laggy on the way to normal mode.
KEYTIMEOUT=1

# Terminal application mode, so the terminfo[] codes below match what the
# terminal actually sends for Home/End/Delete/PageUp/PageDown.
if [[ -n ${terminfo[smkx]} && -n ${terminfo[rmkx]} ]]; then
  function zle-line-init()   { echoti smkx }
  function zle-line-finish() { echoti rmkx }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

# Arrow keys search history by what's already typed, rather than walking it
# blindly. Bound in the main keymap, which `bindkey -v` points at viins.
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# ctrl+space accepts the autosuggestion.
bindkey '^ ' autosuggest-accept

# Space shouldn't trigger history expansion.
bindkey ' ' magic-space

# Navigation and editing keys, for both vi keymaps. These were previously
# inherited from OMZL::key-bindings.zsh, which is no longer loaded — it also did
# an unconditional `bindkey -e` that fought vi mode, and brought 145 lines of
# emacs-isms along with the handful of bindings actually worth having.
for _km in viins vicmd; do
  [[ -n ${terminfo[khome]} ]] && bindkey -M $_km "${terminfo[khome]}" beginning-of-line
  [[ -n ${terminfo[kend]}  ]] && bindkey -M $_km "${terminfo[kend]}"  end-of-line
  [[ -n ${terminfo[kdch1]} ]] && bindkey -M $_km "${terminfo[kdch1]}" delete-char
  [[ -n ${terminfo[kpp]}   ]] && bindkey -M $_km "${terminfo[kpp]}"   up-line-or-history
  [[ -n ${terminfo[knp]}   ]] && bindkey -M $_km "${terminfo[knp]}"   down-line-or-history
  [[ -n ${terminfo[kcbt]}  ]] && bindkey -M $_km "${terminfo[kcbt]}"  reverse-menu-complete
  bindkey -M $_km '^[[3~'   delete-char      # Delete
  bindkey -M $_km '^[[1;5C' forward-word     # ctrl+right
  bindkey -M $_km '^[[1;5D' backward-word    # ctrl+left
  bindkey -M $_km '^[[3;5~' kill-word        # ctrl+delete
done
unset _km

# zsh's vi mode refuses to backspace past the point where insert mode started.
# These restore the behaviour every other editor has.
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char

# `v` in normal mode opens the current command line in $EDITOR (nvim);
# ctrl+x ctrl+e does the same from insert mode.
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v'    edit-command-line
bindkey -M viins '^X^E' edit-command-line

# Note: history search from normal mode is deliberately not bound here. atuin's
# init runs last in .zshrc and claims `/` in vicmd plus ctrl+r in viins, which
# is better than zsh's incremental search. Binding them here would be dead code.
