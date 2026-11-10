[[ -f "$ZDOTDIR/ai.local.zsh" ]] && source "$ZDOTDIR/ai.local.zsh"

alias c='claude'
alias cc='claude --continue'
alias cre='claude --resume'
alias dopus='claude --model opus --dangerously-skip-permissions'
# Extra Claude Code accounts (each shares project history via a projects/ symlink)
alias ccx='CLAUDE_CONFIG_DIR=~/.claude-pai2 claude'      # PAI seat 2
alias ccp='CLAUDE_CONFIG_DIR=~/.claude-personal claude'  # personal subscription
alias cczf='claude --plugin-dir ../cc-marketplace/kzf --plugin-dir ../cc-marketplace/standards'

claude-here() { (cd "${1:-.}" && claude); }
cdiff()       { git diff "$@" | claude -p "Review this diff"; }
