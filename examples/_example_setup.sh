#!/usr/bin/env bash

# Parameter for CI/CD and offline testing
image=${1:-reitzig/texlive-base-luatex}
echo "Will use image ${image}"

# This is another hoop for CI/CD, you can usually ignore it:
tty_params=""
if [[ $- == *i* ]]; then
    tty_params="--interactive --tty"
fi
