#!/bin/sh
echo -ne '\033c\033]0;tiled game\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/tiled game.x86_64" "$@"
