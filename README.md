# dotfiles

Personal macOS dotfiles managed by [chezmoi](https://www.chezmoi.io/).

## Machines

| Host | Source dir | Notes |
|---|---|---|
| `mugen` | `~/work/personal/dotfiles` | MacBook. Origin of this setup. |
| `nerv` | `~/dev/personal/dotfiles` | Has no `~/work`; keeps pyenv/jenv/pnpm (see host module). |

Anything that genuinely differs between machines goes through chezmoi templating
keyed on `.chezmoi.hostname` — never a second copy of a file. Three places use it:

- `dot_config/zsh/host.zsh.tmpl` — per-machine shell setup, sourced from
  `.zshrc` after the shared modules so it can override them. Empty on mugen.
- `dot_gitconfig.tmpl` — shared delta/merge/diff settings; `init.defaultBranch`
  and the `includeIf` paths differ per host.
- `.chezmoiignore` — scopes `kzo-pool` to nerv, the only machine running slots.

The source dir differs per machine, so it lives in machine-local
`~/.config/chezmoi/chezmoi.toml` rather than in this repo.

## Stack

- **Shell**: zsh (no Oh My Zsh), XDG-compliant via `ZDOTDIR`
- **Plugin manager**: [zinit](https://github.com/zdharma-continuum/zinit) with turbo mode
- **Prompt**: [starship](https://starship.rs/) — Catppuccin Mocha palette
- **Terminal**: [Ghostty](https://ghostty.org/) — Catppuccin Mocha theme
- **Multiplexer**: [herdr](https://herdr.dev) — agent-aware, replaces tmux
- **Editor**: [Neovim](https://neovim.io/) 0.12 + [LazyVim](https://www.lazyvim.org/) — Catppuccin Mocha
- **Font**: FiraCode Nerd Font
- **CLI**: eza, bat, ripgrep, fd, fzf, zoxide, atuin, git-delta, lazygit, tree-sitter-cli
- **Runtimes**: [mise](https://mise.jdx.dev/) — Node, bun, and more, with per-project pins

## Bootstrap a new machine

```sh
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Set git identity (this repo then takes over via dot_gitconfig.tmpl)
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# 3. Install tooling
brew install chezmoi starship fzf zoxide atuin eza bat ripgrep fd git-delta \
  zsh-completions neovim lazygit tree-sitter-cli mise herdr k9s jq
brew install --cask font-fira-code-nerd-font ghostty

# 3a. Verify Command Line Tools (needed by Treesitter to compile parsers)
xcode-select -p || xcode-select --install

# 4. Point chezmoi at this machine's source dir, then deploy
mkdir -p ~/.config/chezmoi
printf 'sourceDir = "%s/dev/personal/dotfiles"\n' "$HOME" > ~/.config/chezmoi/chezmoi.toml
chezmoi init --apply git@github.com:alfredw/dotfiles.git

# 5. Install the runtimes this machine's projects pin
mise install

# 6. herdr agent integrations — NOT tracked here (they write into agent-owned
#    config dirs), so they are a per-machine bootstrap step.
herdr integration install claude
herdr integration install codex
herdr integration install opencode
herdr integration status        # all three should read "current"

# 7. Add secrets to the untracked local files
$EDITOR ~/.config/zsh/ai.local.zsh          # see ai.local.zsh.example
```

Step 4 runs `run_once_before_install-zinit.sh`, which clones zinit before the
first apply. The first interactive shell after that installs the zinit plugins
in turbo mode — expect a burst of clone output once, then never again.

## Layout

```
dot_zshenv                      → ~/.zshenv        (XDG vars, ZDOTDIR, PATH seeds)
dot_gitconfig.tmpl              → ~/.gitconfig     (per-host: branch + includeIf)
dot_markdownlint.json           → ~/.markdownlint.json
dot_config/zsh/
  dot_zshrc                     → ~/.config/zsh/.zshrc  (sources the modules below)
  path.zsh                      PATH additions
  options.zsh                   setopt, history
  completions.zsh               compinit, zstyle
  plugins.zsh                   zinit turbo block
  aliases.zsh                   eza/bat/fzf/git aliases
  functions.zsh                 mkcd, extract, GKE bastion + k9s helpers
  ai.zsh                        Claude Code aliases (sources ai.local.zsh)
  host.zsh.tmpl                 per-machine setup (see Machines)
  keybinds.zsh                  bindkey
dot_config/git/
  identity-pai                  work identity, pulled in by includeIf
  identity-personal             personal identity, pulled in by includeIf
dot_config/mise/config.toml     global runtime versions
dot_config/starship.toml        prompt config
dot_config/ghostty/config       terminal config
dot_config/herdr/
  config.toml                   multiplexer config (prefix, theme, keybinds)
  KEYBINDINGS.md                shortcut reference; read it with `herdrkeys`
dot_config/private_k9s/         k9s config, aliases, plugins
dot_config/private_karabiner/   karabiner-elements config
dot_config/gh/                  gh CLI prefs (hosts.yml is ignored)
dot_config/direnv/              direnv config
dot_config/kzo-pool/            nerv only; config.json templated off homeDir
dot_config/nvim/                Neovim 0.12 + LazyVim
  init.lua                      bootstraps lua/config/lazy
  lua/config/lazy.lua           lazy.nvim + LazyVim core + lang extras
  lua/config/{options,keymaps,autocmds}.lua
                                user override hooks (LazyVim auto-sources)
  lua/plugins/colorscheme.lua   Catppuccin Mocha + LazyVim default
  lua/plugins/markdown.lua      in-buffer markdown + mermaid rendering
  lua/plugins/example-overrides.lua
                                placeholder for future tweaks
  lazy-lock.json                committed plugin lockfile
  stylua.toml                   lua formatter config
python-manifests/               records, never applied — see its README
run_once_before_install-zinit.sh.tmpl
                                clones zinit on first apply
```

## Secrets

Never tracked; each has a committed `.example` alongside it. All are listed in
`.chezmoiignore`, so `chezmoi apply` will not create or overwrite them.

| File | Holds |
|---|---|
| `~/.config/zsh/ai.local.zsh` | AI provider API keys |
| `~/.config/kzo-pool/env` | `GH_TOKEN` |
| `~/.config/kzo-pool/env.claude` | `CLAUDE_CODE_OAUTH_TOKEN` |

Also deliberately untracked: `~/.config/gh/hosts.yml` (gh keeps its OAuth token
in the macOS keyring), atuin's sync key, k9s cluster/benchmark/screen-dump
state, karabiner's dated backups, and herdr's logs, sockets and session file.

## Notes

### herdr keybindings

`prefix = "ctrl+b"`, herdr's default. `ctrl+a` was tried first to match the old
tmux binding, but the shared `keybinds.zsh` sets emacs keybindings (`bindkey
-e`) where `ctrl+a` is `beginning-of-line` — herdr would swallow it inside every
pane. `ctrl+b` is not free either (it's `backward-char`), but it is the binding
every herdr user lives with by default, and the arrow keys cover it.

The full shortcut table lives in `dot_config/herdr/KEYBINDINGS.md`, which
chezmoi deploys to `~/.config/herdr/KEYBINDINGS.md` so it is readable on every
machine — run `herdrkeys`. It also records which bindings are ours versus
upstream defaults, and why the prefix moved off `ctrl+a`.

One thing worth knowing before you try to fix it in config: **bindings do not
repeat.** The prefix is single-shot and herdr has no tmux `bind -r` equivalent,
so stepping N workspaces costs N presses of `ctrl+b`. Requested upstream in
[discussion #599](https://github.com/herdrdev/herdr/discussions/599), still
open. Use the indexed jumps (`prefix+shift+1..9`) instead.

Apply config edits without restarting: `herdr server reload-config`, or
`prefix+shift+r`.

### If eza / bat / delta abort with "Library not loaded: libllhttp"

Homebrew ABI drift, not a config problem. `eza`, `bat` and `git-delta` all link
`libgit2`, which links `llhttp`. Installing any of them can pull a newer
`llhttp` and relink `/opt/homebrew/opt/llhttp` to it, leaving the existing
`libgit2` pointing at a `libllhttp.<old>.dylib` that no longer exists under that
path. Homebrew does not rebuild dependents automatically.

```sh
brew upgrade libgit2   # rebuilt against the current llhttp
brew cleanup           # drop the orphaned old versions
```

Worth knowing because `core.pager = delta` means this breaks `git diff` and
`git log` too — and only in a real terminal, since git pages only to a TTY. A
script calling git will look perfectly healthy while interactive use is broken.

### lazy-lock.json and the silent `chezmoi apply` skip

`lazy-lock.json` is the file most likely to drift, because nvim rewrites it
whenever plugins install or update. Two things to know:

**`chezmoi apply` will not overwrite a file that changed since chezmoi last
wrote it** — it asks first, and in a non-interactive context it simply skips.
That produces a confusing loop: `apply` leaves the old lockfile in place,
`:Lazy restore` then restores to *that* and writes it back, so the drift never
clears. Break it with `--force`:

```sh
chezmoi apply --force ~/.config/nvim/lazy-lock.json
nvim --headless "+Lazy! restore" +qa
chezmoi status                      # should now be empty
```

**Pick one machine to bump plugin versions on.** Run `:Lazy sync` there,
`chezmoi re-add` the lockfile, commit; then on the other machine pull and use
the force-apply sequence above. Both machines updating independently just
produces lockfile churn.

Stray plugin directories from a previous config are removed with
`:Lazy clean` — compare `ls ~/.local/share/nvim/lazy/ | wc -l` against
`jq 'keys|length' ~/.config/nvim/lazy-lock.json`.

### Neovim first launch

After `chezmoi apply` deploys the nvim config, the very first `nvim` launch will:
1. Bootstrap `lazy.nvim` (clone into `~/.local/share/nvim/lazy/`)
2. Install all plugins from `lazy-lock.json` (~1–2 min)
3. Mason auto-installs LSP servers, formatters, linters, DAP adapters for Python/TS/Rust (~2–3 min, watch the bottom-right progress UI)
4. Compile Treesitter parsers using the system `tree-sitter` CLI

### Runtime versions (mise)

`mise` is activated in `.zshrc` via `eval "$(mise activate zsh)"`. Global
defaults live in `~/.config/mise/config.toml`. Per-project overrides: a
`mise.toml`, `.tool-versions`, or — because
`idiomatic_version_file_enable_tools = ["node"]` is set — a plain `.nvmrc`.

One trap: if a project pins a version mise hasn't installed, mise prints
`WARN missing: node@X` and then falls through to whatever `node` is next on
`PATH` (on nerv, Homebrew's, which `opencode` depends on). It does not fail.
Run `mise install` after cloning a project so the pin is actually honoured.

### Tree-sitter CLI

The new `nvim-treesitter` `main` branch (post-rewrite, April 2026) **requires**
the system `tree-sitter` CLI to compile parsers locally. We install it via
`brew install tree-sitter-cli` rather than letting Mason manage it — cleaner
dependency model, available system-wide, single source of truth. **Do not**
install Mason's `tree-sitter-cli` package — it duplicates and shadows the
system binary.
