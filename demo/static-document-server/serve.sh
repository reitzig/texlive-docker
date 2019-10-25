#!/usr/bin/env bash

# What we want to run is just
#
#   docker build --tag tld-demo-serve-static .
#
# While this _works_, it doesn't lend itself well to
# re-building the server image: in multi-stage builds,
# caching of layers doesn't "just work" as it does for
# regular builds.
#
# Hence, this more convoluted construct to tell Docker
# explicitly to use its usual smarts:

docker build \
    --target build \
    --cache-from tld-demo-serve-static:build \
    --tag tld-demo-serve-static:build \
    .
docker build \
    --cache-from tld-demo-serve-static:build \
    --cache-from tld-demo-serve-static:latest \
    --tag tld-demo-serve-static \
    .

echo ""
echo "Try and access in a browser: http://localhost:8080/"
echo "Stop with CTRL+C"

docker run --publish 8080:80 --rm tld-demo-serve-static
