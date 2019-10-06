#!/bin/bash

# This is a medium-complexity approach.
# A document in the current directory is built but
# the container is kept around; the document can be rebuilt
# as sources (or dependencies) change without incurring the
# full overhead.

# build image with: 
#   docker build -t texlive-base-luatex --build-arg "profile=base-luatex" .

docker run -it --name=tld-example \
    -v `pwd`:/work/src:ro \
    texlive-base-luatex \
    work 'lualatex hello_world.tex'

docker start -ai tld-example 
docker cp tld-example:/work/out/ ./ \
 && mv out/* ./ \
 && rm -rf out # You could also use a bind-mount instead
# Repeat these steps as needed

docker rm -f tld-example > /dev/null
