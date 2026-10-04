#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
test_state=$(mktemp -d)
trap 'rm -rf "$test_state"' EXIT HUP INT TERM
export XDG_CONFIG_HOME="$test_state/config"
export XDG_DATA_HOME="$test_state/data"
export XDG_STATE_HOME="$test_state/state"
export XDG_CACHE_HOME="$test_state/cache"
export NVIM_LOG_FILE="$test_state/nvim.log"
"${NVIM:-nvim}" --headless -u tests/minimal.vim -i NONE \
    -c "lua dofile('tests/run.lua')"
