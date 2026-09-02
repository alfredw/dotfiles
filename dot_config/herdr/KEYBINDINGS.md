# herdr keybindings

Deployed by chezmoi to `~/.config/herdr/KEYBINDINGS.md`. Source of the bindings
marked **ours** is `dot_config/herdr/config.toml`; the rest are upstream defaults
recorded here for reference. Written against herdr 0.8.0 (protocol 19) —
`herdr --default-config` prints the authoritative annotated set.

Read this anywhere with `herdrkeys`.

`prefix` is **`ctrl+a`**. Every chord is prefix-then-key: press `ctrl+a`,
release, then the key. The prefix arms for exactly one keypress.

Hierarchy is **workspace → tab → pane**. A tab holds panes; a workspace holds
tabs. Agents are a cross-cutting view over panes, not a fourth level.

## Panes

| Keys | Action | |
|---|---|---|
| `prefix` `h` `j` `k` `l` | focus pane left / down / up / right | |
| `prefix` `a` | last pane — bounce between the two you're working in (tmux-style prefix+prefix) | ours |
| `prefix` `v` | split vertically (side by side) | |
| `prefix` `-` | split horizontally (stacked) | |
| `prefix` `x` | close pane | |
| `prefix` `e` | open this pane's scrollback in `$EDITOR` (nvim) | ours |

## Tabs

| Keys | Action | |
|---|---|---|
| `prefix` `c` | new tab — prompts for a name | |
| `prefix` `n` / `p` | next / previous tab | |
| `prefix` `1`..`9` | jump to tab N | ours |
| `prefix` `shift+x` | close tab | |

## Workspaces

Vertical, matching the sidebar.

| Keys | Action | |
|---|---|---|
| `prefix` `shift+j` / `shift+k` | next / previous workspace | ours |
| `prefix` `shift+1`..`9` | jump to workspace N | ours |
| `prefix` `shift+n` | new workspace — no name prompt | |
| `prefix` `shift+g` | new git worktree → `~/dev/worktrees/<repo>/<branch-slug>` | |

## Agents

Horizontal.

| Keys | Action | |
|---|---|---|
| `prefix` `shift+l` / `shift+h` | next / previous agent | ours |
| `prefix` `alt+1`..`9` | focus agent N | ours |

## Popups and meta

| Keys | Action | |
|---|---|---|
| `prefix` `alt+g` | lazygit in a popup (90%×90%) | ours |
| `prefix` `alt+k` | k9s in a popup (95%×90%) | ours |
| `prefix` `b` | toggle sidebar | |
| `prefix` `shift+r` | reload config | |
| `prefix` `?` | in-app keybinding help | |

Movement mnemonic: `hjkl` = panes, `shift+jk` = workspaces (vertical),
`shift+hl` = agents (horizontal).

## Notes

**Why `ctrl+a`.** It matches the old tmux prefix, and `keybinds.zsh` runs
`bindkey -v`, where `ctrl+a` is unbound in both vi keymaps, so the shell loses
nothing. It briefly sat on herdr's default `ctrl+b` while zsh was in emacs mode
(`ctrl+a` = `beginning-of-line`). Inside panes, herdr does swallow nvim's
`ctrl+a` (increment) and the home-of-line `ctrl+a` in agent prompts; use
`Home` or `0` there.

**No repeatable bindings.** The prefix is single-shot, and herdr has no tmux
`bind -r` equivalent — holding `shift+j` will not keep stepping through
workspaces, and each step needs a fresh `ctrl+a`. Requested upstream in
[discussion #599](https://github.com/herdrdev/herdr/discussions/599), still
open, not implemented. Prefer the indexed jumps (`prefix+shift+1..9`) over
stepping. Note that `agent_panel_sort = "priority"` means the sidebar reorders
as agents change state, so those indices are not stable positions — set it to
`"spaces"` if you want them to be.

**Applying config edits.** `herdr server reload-config`, or `prefix+shift+r`.
After editing the chezmoi source, `chezmoi apply ~/.config/herdr/config.toml`
first.
