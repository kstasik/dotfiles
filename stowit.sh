#!/bin/sh

SOURCE="$(git rev-parse --show-toplevel)"
TARGET="$HOME/"

stow --dotfiles --dir=$SOURCE --target=$TARGET . --no-folding
