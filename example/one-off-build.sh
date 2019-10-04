#!/bin/bash

# build image with: 
#   docker build -t texlive-base-luatex --build-arg "profile=base-luatex" .

mkdir -p out
docker run --name=tld-example \
    -v `pwd`:/work/src:ro \
    -v `pwd`/out:/work/out \
    texlive-base-luatex work 'lualatex hello_world.tex'
    #texlive-minimal work 'luatex hello_world.tex'
docker cp tld-example:/work/out/ ./
mv out/* ./
docker rm tld-example > /dev/null
rm -rf out

# TODO: Showcase rebuild through docker start -a
# TODO: Write a small script/program to wrap these?