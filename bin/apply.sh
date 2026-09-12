#!/usr/bin/env bash
# tmurdr — apply the tmux-parity keymap to your Herdr config.toml.
# Safe to run standalone or via `herdr plugin action invoke tmurdr.apply`.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="${HERDR_PLUGIN_ROOT:-$(dirname "$here")}"
keys="$root/keys.toml"

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/herdr"
config="$config_dir/config.toml"
herdr_bin="${HERDR_BIN_PATH:-$(command -v herdr || true)}"

[ -f "$keys" ] || { echo "tmurdr: keys.toml not found at $keys" >&2; exit 1; }
mkdir -p "$config_dir"
[ -f "$config" ] || : > "$config"

backup="$config.tmurdr-bak-$(date +%Y%m%d%H%M%S)"
cp "$config" "$backup"
echo "tmurdr: backed up current config to $backup"

# Drop any existing [keys], [keys.*] and [[keys.*]] tables, keeping everything
# else ([theme], [ui], ...) intact. A second [keys] table would be a TOML error.
tmp="$(mktemp)"
awk '
  /^#+[[:space:]]*tmurdr:/                             { next }
  /^[[:space:]]*\[\[?keys(\.[^]]*)?\]\]?[[:space:]]*$/ { skip = 1; next }
  /^[[:space:]]*\[/                                    { skip = 0 }
  !skip                                                { print }
' "$config" > "$tmp"

# Trim trailing blank lines, then append the tmurdr keymap.
awk 'BEGIN{n=0} {lines[NR]=$0} END{for(i=NR;i>0;i--){if(lines[i]!~/^[[:space:]]*$/){n=i;break}} for(i=1;i<=n;i++) print lines[i]}' "$tmp" > "$config"
{ echo; echo "# tmurdr: tmux keybindings ──────────────────────────────────"; cat "$keys"; } >> "$config"
rm -f "$tmp"

if [ -n "$herdr_bin" ]; then
  if ! "$herdr_bin" config check 2>&1 | tee /dev/stderr | grep -q '^config: ok'; then
    cp "$backup" "$config"
    echo "tmurdr: config check failed — restored $backup, nothing changed." >&2
    exit 1
  fi
  "$herdr_bin" server reload-config >/dev/null 2>&1 \
    && echo "tmurdr: keymap applied and server reloaded." \
    || echo "tmurdr: keymap applied. Start Herdr (or reload) to pick it up."
else
  echo "tmurdr: keymap applied. 'herdr' not on PATH, so it was not validated or reloaded." >&2
fi
