# The foundation this repo's configs depend on — deliberately NOT a full
# `brew bundle dump`. Each machine keeps its own extras (nerv carries ~150
# formulae of work tooling, mugen ~80); this file is only what the dotfiles
# themselves require, so any machine can be brought to a common baseline.
#
# Check without installing:
#   brew bundle check   --file="$(chezmoi source-path)/Brewfile" --verbose
# Install what's missing:
#   brew bundle install --file="$(chezmoi source-path)/Brewfile"
#
# Not deployed to $HOME (see .chezmoiignore) — intentionally, so a stray
# `brew bundle dump --force` can't overwrite this curated list with a full
# machine dump.

tap "homebrew/bundle"

# ── Shell ────────────────────────────────────────────────────────────────────
brew "starship"          # prompt; config in dot_config/starship.toml
brew "zsh-completions"   # FPATH addition, see completions.zsh
# zinit is not brewed — run_once_before_install-zinit.sh clones it.

# ── Runtimes ─────────────────────────────────────────────────────────────────
brew "mise"              # node/bun/java/python; config in dot_config/mise/

# ── History & navigation ─────────────────────────────────────────────────────
brew "atuin"             # shell history; claims ctrl+r and / in vicmd
brew "zoxide"            # the `cd`/`cdi` aliases
brew "fzf"               # key-bindings.zsh + completion.zsh sourced in .zshrc

# ── Files & text ─────────────────────────────────────────────────────────────
brew "eza"               # the ls/ll/la/lt/llt aliases
brew "bat"               # the cat/less aliases; BAT_THEME set in aliases.zsh
brew "ripgrep"
brew "fd"                # FZF_DEFAULT_COMMAND
brew "jq"

# ── Git ──────────────────────────────────────────────────────────────────────
brew "git"
brew "git-delta"         # core.pager and interactive.diffFilter in .gitconfig
brew "lazygit"           # bound to prefix+alt+g in the herdr config

# ── Editor ───────────────────────────────────────────────────────────────────
brew "neovim"
brew "tree-sitter-cli"   # REQUIRED by nvim-treesitter's main branch to compile
                         # parsers. Do not use Mason's copy — it shadows this.

# ── Terminal & multiplexer ───────────────────────────────────────────────────
brew "herdr"             # config in dot_config/herdr/config.toml
brew "chezmoi"           # manages this repo

# ── Kubernetes ───────────────────────────────────────────────────────────────
brew "k9s"               # config in dot_config/private_k9s/
                         # bound to prefix+alt+k in the herdr config

# ── Casks ────────────────────────────────────────────────────────────────────
cask "ghostty"                     # config in dot_config/ghostty/config
cask "font-fira-code-nerd-font"    # referenced by ghostty + starship glyphs
cask "karabiner-elements"          # config in dot_config/private_karabiner/
