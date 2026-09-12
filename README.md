# tmurdr

tmux muscle memory for [Herdr](https://herdr.dev).

Herdr is a terminal workspace manager, but its default keymap isn't tmux's. If your
fingers already know `prefix |` for a split and `prefix c` for a new window, tmurdr
remaps Herdr's `[keys]` so they keep working.

`ctrl+b` becomes `ctrl+space`, and the rest of the tmux keymap follows.

## Install

```sh
herdr plugin install sergiopx/tmurdr
herdr plugin action invoke tmurdr.apply
```

Or without the plugin system:

```sh
git clone https://github.com/sergiopx/tmurdr && bash tmurdr/bin/apply.sh
```

Either way, `apply` backs up your `config.toml` first, validates the result with
`herdr config check`, restores the backup if validation fails, and reloads the
running server. `herdr plugin action invoke tmurdr.revert` undoes the last apply.

## The mapping

Herdr's *workspaces* stand in for tmux *sessions*, and its *tabs* for *windows*.

| tmux | tmurdr | action |
|---|---|---|
| `C-Space` | `ctrl+space` | prefix |
| `prefix \|` / `-` | same | split vertical / horizontal |
| `C-h/j/k/l` | same | focus pane (no prefix) |
| `prefix H/J/K/L` | `prefix+shift+h…` | resize pane |
| `prefix x` / `X` / `C-x` | same | close pane / tab / workspace |
| `prefix c` / `,` | same | new / rename tab |
| `prefix n` / `p` | same | next / previous tab |
| `M-1`…`M-9` | `alt+1..9` | jump to tab |
| `prefix s` / `S` | same | workspace navigation / new workspace |
| `prefix d` | same | detach |
| `prefix r` | same | reload config |
| `prefix z` / `o` / `;` | same | zoom / cycle pane / last pane |
| `prefix ?` | same | help |

Inside workspace navigation (`prefix s`), `j`/`k` move between spaces and `h`/`l`
move between panes — Herdr defaults to arrow keys there.

## What doesn't carry over

Honest list, because these are Herdr limits rather than oversights:

- **`ctrl+h/j/k/l` is global.** tmux users usually pair those with
  [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator), which
  checks whether Vim has focus and passes the key through. Herdr has no such hook,
  so `ctrl+l` (clear) and `ctrl+k` are swallowed everywhere and Vim's own split
  navigation won't see them. If that bothers you, set
  `focus_pane_left = "prefix+h"` and friends in `keys.toml` before applying.
- **One key per action.** Herdr's `previous_tab` takes a single binding, so tmux
  setups that reach a window by `prefix p` *and* `S-Left` *and* `M-1` lose one.
  tmurdr keeps `prefix p`/`n` and `alt+1..9`; `S-Left`/`S-Right` are dropped.
- **Pane up/down in navigation mode moved to the arrows,** because `j`/`k` were
  reassigned to spaces.
- **No Herdr equivalent** exists for `synchronize-panes`, `clear-history`, or
  copy-mode's `prefix [` (`prefix e` opens scrollback in `$EDITOR` instead).

## Customising

`keys.toml` is a plain Herdr `[keys]` block — edit it, re-run `apply`, and the
validate-or-restore path keeps a typo from leaving you with a broken config.
Every binding name is documented in `herdr --default-config`.

Note that `herdr config check` validates each binding's *syntax* but does not
detect two actions claiming the same key; a collision fails silently at runtime.

## Licence

MIT
