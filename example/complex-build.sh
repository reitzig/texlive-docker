#!/usr/bin/env bash

# This showcases how to use a build script, base on the "one-off build".
# Other examples can be adapted similarly.

# build image with:
#   docker build -t texlive-base-luatex --build-arg "profile=base-luatex" .

mkdir -p out

docker run -it --rm --name=tld-example \
    -v `pwd`:/work/src:ro \
    -v `pwd`/out:/work/out \
    -e 'BUILDSCRIPT=_custom-build-script.sh' \
    texlive-base-luatex \
    work

mv out/* ./ && rm -rf out
