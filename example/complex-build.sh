#!/usr/bin/env bash

# This showcases how to use a build script, base on the "one-off build".
# Other examples can be adapted similarly.

# build image with:
#   docker build -t texlive-base-luatex --build-arg "profile=base-luatex" .

mkdir -p out

docker run --name=tld-example --interactive --tty --rm  \
    --volume `pwd`:/work/src:ro \
    --volume `pwd`/out:/work/out \
    --env 'BUILDSCRIPT=_custom-build-script.sh' \
    texlive-base-luatex \
    work

mv out/* ./ && rm -rf out
