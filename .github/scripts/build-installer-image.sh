#!/usr/bin/env bash

source "$(dirname "${0}")/_shared_functions.sh"

set -e

installer_image=${TEXLIVE_INSTALLER_IMAGE:-'texlive-installer:latest'}

ctan_mirror="$(choose_ctan_mirror)"
echo "Will use CTAN mirror ${ctan_mirror}"

docker build --no-cache \
    --build-arg "ctan_mirror=${ctan_mirror}" \
    --target "texlive-installer" \
    --tag "${installer_image}" \
    .

docker run --rm "${installer_image}"
