#!/usr/bin/env bash

source "$(dirname $0)/_example_setup.sh" "${@}"

# This is a medium-complexity approach.
# A document in the current directory is built but
# the container is kept around; the document can be rebuilt
# as sources (or dependencies) change without incurring the
# full overhead.

docker run --name=tld-example ${tty_params} \
    --volume `pwd`:/work/src:ro \
    ${image} \
    work lualatex hello_world.tex

docker start --attach ${tty_params} tld-example
docker cp tld-example:/work/out/ ./ \
 && mv out/* ./ \
 && rm -rf out # You could also use a bind-mount instead
# Repeat these steps as needed

docker rm --force tld-example > /dev/null
