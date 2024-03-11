#!/usr/bin/env bash

set -e

installer_image=${TEXLIVE_INSTALLER_IMAGE:-'texlive-installer:latest'}

# NB: Can't seem to resolve mirrors.ctan.org from within 'docker build', so do it here:
ctan_mirror="$(curl -Ls -o /dev/null -w '%{url_effective}' https://mirrors.ctan.org)"
echo "Will use CTAN mirror ${ctan_mirror}"

docker build --no-cache \
    --build-arg "ctan_mirror=${ctan_mirror}" \
    --target "texlive-installer" \
    --tag "${installer_image}" \
    .

docker run --rm "${installer_image}"
