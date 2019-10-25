#!/usr/bin/env bash

# This approach is good for builds with complicated setup:
# create a new image that runs whatever you want.

# build base image with:
#   docker build -t texlive-base-luatex --build-arg "profile=base-luatex" .

docker build --tag tld-hello-world .
docker run --rm tld-hello-world:latest > hello_world.pdf
