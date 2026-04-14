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
    OMZL::key-bindings.zsh
