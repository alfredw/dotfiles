# dotfiles

Personal macOS dotfiles managed by [chezmoi](https://www.chezmoi.io/).

## Stack

- **Shell**: zsh (no Oh My Zsh)
- **Plugin manager**: [zinit](https://github.com/zdharma-continuum/zinit) with turbo mode
- **Prompt**: [starship](https://starship.rs/) — Catppuccin Mocha palette
- **Terminal**: [Ghostty](https://ghostty.org/) — Catppuccin Mocha theme
- **Font**: FiraCode Nerd Font
- **CLI**: eza, bat, ripgrep, fd, fzf, zoxide, atuin, git-delta

## Bootstrap a new machine

```sh
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Set git identity
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# 3. Install tooling
brew install chezmoi starship fzf zoxide atuin eza bat ripgrep fd git-delta zsh-completions
brew install --cask font-fira-code-nerd-font ghostty

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
dot_config/starship.toml        prompt config
dot_config/ghostty/config       terminal config
run_once_before_install-zinit.sh.tmpl
                                clones zinit on first apply
```

## Secrets

`~/.config/zsh/ai.local.zsh` is gitignored and created manually per-machine. It should look like:

```sh
export ANTHROPIC_API_KEY="sk-ant-..."
```
