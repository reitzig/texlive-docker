#!/usr/bin/env bash

set -euo pipefail

image_tag_list="${1}"

# TODO: Include tag annotation?
# TODO: include some form of changelog?

echo -e "### Published images\n"
for tag in $(grep -ve ':latest$' "${image_tag_list}"); do
    echo " - [${tag}](https://hub.docker.com/r/${tag%%:*})"
done
