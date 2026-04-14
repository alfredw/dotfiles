# dotfiles

Personal macOS dotfiles managed by [chezmoi](https://www.chezmoi.io/).

## Stack

- **Shell**: zsh (no Oh My Zsh)
- **Plugin manager**: [zinit](https://github.com/zdharma-continuum/zinit) with turbo mode
- **Prompt**: [starship](https://starship.rs/) — Catppuccin Mocha palette
- **Terminal**: [Ghostty](https://ghostty.org/) — Catppuccin Mocha theme
- **Editor**: [Neovim](https://neovim.io/) 0.12 + [LazyVim](https://www.lazyvim.org/) — Catppuccin Mocha
- **Font**: FiraCode Nerd Font
- **CLI**: eza, bat, ripgrep, fd, fzf, zoxide, atuin, git-delta, lazygit, tree-sitter-cli
- **Runtimes**: [mise](https://mise.jdx.dev/) — polyglot version manager (Node, Python, etc.) with per-project `.mise.toml`

## Bootstrap a new machine

```sh
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Set git identity
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# 3. Install tooling
brew install chezmoi starship fzf zoxide atuin eza bat ripgrep fd git-delta zsh-completions \
  neovim lazygit tree-sitter-cli mise
brew install --cask font-fira-code-nerd-font ghostty

# 3a. Verify Command Line Tools (needed by Treesitter to compile parsers)
xcode-select -p || xcode-select --install

# 4. Deploy dotfiles
chezmoi init --apply git@github-personal:alfredw/dotfiles.git

# 5. Add secrets (API keys etc) to the untracked local file
$EDITOR ~/.config/zsh/ai.local.zsh
```

## Layout

```
dot_zshenv                      → ~/.zshenv        (XDG, PATH seeds)
dot_zshrc                       → ~/.zshrc         (bootstrap, sources split files)
dot_config/zsh/
  path.zsh                      PATH additions
  options.zsh                   setopt, history
  completions.zsh               compinit, zstyle
  plugins.zsh                   zinit turbo block
  aliases.zsh                   eza/bat/fzf/git aliases
  functions.zsh                 mkcd, extract
  ai.zsh                        Claude Code aliases (sources ai.local.zsh)
  keybinds.zsh                  bindkey
dot_config/mise/config.toml     global runtime versions (Node LTS)
dot_config/starship.toml        prompt config
dot_config/ghostty/config       terminal config
dot_config/nvim/                Neovim 0.12 + LazyVim
  init.lua                      bootstraps lua/config/lazy
  lua/config/lazy.lua           lazy.nvim + LazyVim core + lang extras
  lua/config/{options,keymaps,autocmds}.lua
                                user override hooks (LazyVim auto-sources)
  lua/plugins/colorscheme.lua   Catppuccin Mocha + LazyVim default
  lua/plugins/example-overrides.lua
                                placeholder for future tweaks
  lazy-lock.json                committed plugin lockfile
  stylua.toml                   lua formatter config
run_once_before_install-zinit.sh.tmpl
                                clones zinit on first apply
```

## Secrets

`~/.config/zsh/ai.local.zsh` is gitignored and created manually per-machine. It should look like:

```sh
export ANTHROPIC_API_KEY="sk-ant-..."
```

## Notes

### Neovim first launch

After `chezmoi apply` deploys the nvim config, the very first `nvim` launch will:
1. Bootstrap `lazy.nvim` (clone into `~/.local/share/nvim/lazy/`)
2. Install all 41 plugins from `lazy-lock.json` (~1–2 min)
3. Mason auto-installs LSP servers, formatters, linters, DAP adapters for Python/TS/Rust (~2–3 min, watch the bottom-right progress UI)
4. Compile Treesitter parsers using the system `tree-sitter` CLI

### Runtime versions (mise)

`mise` is activated in `.zshrc` via `eval "$(mise activate zsh)"`. Global defaults live in `~/.config/mise/config.toml` (Node LTS). Per-project overrides: drop a `.mise.toml` (or `.tool-versions`) at the project root and `mise install` to pin language versions. Replaces `nvm`/`pyenv`/`rbenv` in one tool.

### Tree-sitter CLI

The new `nvim-treesitter` `main` branch (post-rewrite, April 2026) **requires** the system `tree-sitter` CLI to compile parsers locally. We install it via `brew install tree-sitter-cli` rather than letting Mason manage it — cleaner dependency model, available system-wide, single source of truth. **Do not** install Mason's `tree-sitter-cli` package — it duplicates and shadows the system binary.
