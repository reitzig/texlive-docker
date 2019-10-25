#!/usr/bin/env bash

source "$(dirname $0)/_example_setup.sh" "${@}"

# This approach is good for builds with complicated setup:
# create a new image that runs whatever you want.

docker build --tag tld-hello-world --build-arg "base_image=${image}" .
docker run --rm tld-hello-world:latest > hello_world.pdf
docker rmi tld-hello-world
