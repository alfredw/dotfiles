zinit wait lucid for \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    Aloxaf/fzf-tab

# No Oh My Zsh snippets. Four used to load here — OMZP::git, OMZL::git.zsh,
# OMZL::completion.zsh and OMZL::key-bindings.zsh — and each was either
# redundant or actively harmful:
#
#   OMZP::git              197 aliases, of which we wanted 7. Because turbo
#                          loads after aliases.zsh, it silently redefined gcm
#                          from `git commit -m` to `git checkout $(git_main_branch)`.
#   OMZL::git.zsh          18 git *prompt* helpers (git_prompt_info,
#                          parse_git_dirty, ...). starship computes its own git
#                          status, so none of them were ever called.
#   OMZL::key-bindings.zsh unconditional `bindkey -e`, which reverted vi mode on
#                          every shell. Its useful bindings (Home/End/Delete,
#                          ctrl+arrow words, PageUp/Down, shift+tab) are now in
#                          keybinds.zsh directly.
#   OMZL::completion.zsh   overlapped completions.zsh, which sets its own zstyles.
