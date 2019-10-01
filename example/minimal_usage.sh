#!/bin/bash

rm -rf out/
docker run --name=tld-example -v `pwd`:/work/src:ro texlive-base work 'lualatex hello_world.tex'
docker cp tld-example:/work/out/ ./
docker rm tld-example

# TODO: Showcase rebuild through docker start -a