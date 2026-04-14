[[ -f "$ZDOTDIR/ai.local.zsh" ]] && source "$ZDOTDIR/ai.local.zsh"

alias c='claude'
alias cc='claude --continue'
alias cr='claude --resume'
alias dopus='claude --model opus --dangerously-skip-permissions'

claude-here() { (cd "${1:-.}" && claude); }
cdiff()       { git diff "$@" | claude -p "Review this diff"; }
