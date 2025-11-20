#!/bin/sh
printf '\033c\033]0;%s\a' Visualisation
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Visualisation.x86_64" "$@"
