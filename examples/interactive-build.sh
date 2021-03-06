#!/usr/bin/env bash

source "$(dirname $0)/_example_setup.sh" "${@}"

# This is the most flexible approach:
#
#   - copy files in and out of the container at will
#   - run arbitrary commands inside the container
#
# With this approach, you can effectively use the
# container TeXlive as if you had installed it on your
# machine, without any convenience wrappers.

# Start the container: it will not run any command yet!
docker run --name=tld-example --detach --rm \
    ${image} hold

docker cp . tld-example:/work/src/ # You could also use a bind-mount instead
docker exec tld-example work 'lualatex hello_world.tex'
    # NB: You don't _have_ to use `(entrypoint) work`, it just takes care of
    #     the default file "flow" and dependency handling.
docker cp tld-example:/work/out/ ./ \
    && mv out/* ./ \
    && rm -rf out # You could also use a bind-mount instead
# Repeat these steps, maybe with modifications, as needed.

# Use
#   docker exec tld-example clean
# to empty out the working directory and let lualatex start from scratch.

# Use
#   docker exec -it bash
# to step "into" the container for debugging of full low-level access.

docker rm --force tld-example > /dev/null
