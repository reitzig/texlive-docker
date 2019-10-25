#!/usr/bin/env bash

set -eu

image=${1}
example=${2}

cd example
./${example}.sh ${image}
[[ -f hello_world.log ]] && [[ -f hello_world.pdf ]]
rm -f hello_world.log hello_world.pdf
