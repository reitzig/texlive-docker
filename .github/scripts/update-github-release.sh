#!/usr/bin/env bash

source "$(dirname "${0}")/_shared_functions.sh"

set -eu

release_id="${1}"
# shellcheck disable=SC2153 # false positive
image_tag_list="${IMAGE_TAG_LIST}"

# Get current values
curl -siX GET "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/${release_id}" \
     -H "Authorization: token ${GITHUB_TOKEN}" \
     -o "${CURL_OUT}"
process_curl_response || exit 1

release_name="$(print_curl_response_json | jq '."name"' )"
release_body="$(print_curl_response_json | jq '."body" // ""' )"

# Remove version prefix from title
new_name="${release_name//@(pre-|release-)/}"

# Add list with new images to body
function list_entry {
    image_tag=${1}

    echo " - [${image_tag}](https://hub.docker.com/r/${image_tag%%:*})\r\n"
}
export -f list_entry

# TODO: Include tag annotation?
# TODO: include some form of changelog?

new_body="$(tr -d '\n' << BODY
${release_body%\"} \\r\\n \\r\\n

### Published images \\r\\n \\r\\n
# shellcheck disable=SC2016 # false positive
$(grep -ve ':latest$' "${image_tag_list}" | xargs -n 1 -I {} bash -c 'list_entry "${@}"' _ {})"

BODY
)"

# Update release
curl -siX PATCH "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/${release_id}" \
     -H "Authorization: token ${GITHUB_TOKEN}" \
     -o "${CURL_OUT}" \
     -d @- \
<< PAYLOAD
{
    "name": ${new_name},
    "body": ${new_body},
    "draft": false
}

PAYLOAD
process_curl_response || exit 1
