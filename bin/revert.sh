#!/usr/bin/env bash
# tmurdr — restore the most recent config.toml backup tmurdr created.
set -euo pipefail

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/herdr"
config="$config_dir/config.toml"
herdr_bin="${HERDR_BIN_PATH:-$(command -v herdr || true)}"

latest="$(ls -1t "$config".tmurdr-bak-* 2>/dev/null | head -1 || true)"
[ -n "$latest" ] || { echo "tmurdr: no tmurdr backup found in $config_dir" >&2; exit 1; }

cp "$latest" "$config"
echo "tmurdr: restored $latest"
[ -n "$herdr_bin" ] && "$herdr_bin" server reload-config >/dev/null 2>&1 \
  && echo "tmurdr: server reloaded." || true
