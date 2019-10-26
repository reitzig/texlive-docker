#!/usr/bin/env bash

# Parameter for CI/CD;
# build the image matching the default value with:
#   docker build --tag texlive-base-luatex --build-arg "profile=base-luatex" .
image=${1:-texlive-base-luatex}
echo "Will use image ${image}"

# This is another hoop for CI/CD, you can usually ignore it:
tty_params=""
if [[ $- == *i* ]]; then
    tty_params="--interactive --tty"
fi
