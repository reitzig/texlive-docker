#!/usr/bin/env bash

source "$(dirname $0)/_example_setup.sh" "${@}"

# This showcases how to use a build script, base on the "one-off build".
# Other examples can be adapted similarly.

mkdir -p out

docker run --name=tld-example ${tty_params} --rm  \
    --volume `pwd`:/work/src:ro \
    --volume `pwd`/out:/work/out \
    --env 'BUILDSCRIPT=_custom-build-script.sh' \
    ${image} \
    work

mv out/* ./ && rm -rf out
