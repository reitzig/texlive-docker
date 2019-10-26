#!/usr/bin/env bash

set -e

installer_image=${TEXLIVE_INSTALLER_IMAGE:-'texlive-installer:latest'}

docker build --no-cache \
    --target "texlive-installer" \
    --tag "${installer_image}" \
    .

docker run --rm "${installer_image}"
