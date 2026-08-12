zinit wait lucid for \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    Aloxaf/fzf-tab

zinit wait lucid for \
    OMZP::git \
    OMZL::git.zsh \
    OMZL::completion.zsh \
    atload'source "$ZDOTDIR/keybinds.zsh"' \
        OMZL::key-bindings.zsh

# The atload above is load-bearing. OMZL::key-bindings.zsh does an
# unconditional `bindkey -e`, and because these snippets load in turbo mode
# they run *after* the module loop has already sourced keybinds.zsh — so vi
# mode would be silently reverted to emacs. Re-sourcing keybinds.zsh puts it
# back. OMZ's own bindings survive: it binds -M emacs and -M viins in pairs.
