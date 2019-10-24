#!/usr/bin/env bash

# This is the most flexible approach:
#
#   - copy files in and out of the container at will
#   - run arbitrary commands inside the container
#
# With this approach, you can effectively use the
# container TeXlive as if you had installed it on your
# machine, without any convenience wrappers.

# build image with:
#   docker build -t texlive-base-luatex --build-arg "profile=base-luatex" .

# Start the container: it will not run any command yet!
docker run --rm -d --name=tld-example \
    texlive-base-luatex hold

docker cp . tld-example:/work/src/ # You could also use a bind-mount instead
docker exec tld-example entrypoint work 'lualatex hello_world.tex'
docker cp tld-example:/work/out/ ./ \
    && mv out/* ./ \
    && rm -rf out # You could also use a bind-mount instead
# Repeat these steps, maybe with modifications, as needed.

# Use
#   docker exec tld-example entrypoint clean
# to empty out the working directory and let lualatex start from scratch.

# Use
#   docker exec -it bash
# to step "into" the container for debugging of full low-level access.

docker rm -f tld-example > /dev/null
