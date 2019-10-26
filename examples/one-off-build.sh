#!/usr/bin/env bash

source "$(dirname $0)/_example_setup.sh" "${@}"

# This is the most ad-hoc approach: a single command will build
# a LaTeX document in the current folder, once, and remove the
# container again.

mkdir -p out

docker run --name=tld-example ${tty_params} --rm \
    --volume `pwd`:/work/src:ro \
    --volume `pwd`/out:/work/out \
    ${image} \
    work 'lualatex hello_world.tex'

mv out/* ./ && rm -rf out

# Nota bene: the output files now belong to root;
#            this is an unfortunate restriction of docker.
#            See `repeated-build.sh` for a way to avoid this.
