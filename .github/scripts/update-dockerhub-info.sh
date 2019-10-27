#!/usr/bin/env bash

source "$(dirname $0)/_shared_functions.sh"

# TODO: It would be nicer to use the original action:
#           https://github.com/peter-evans/dockerhub-description/blob/master/entrypoint.sh
#       But since we can't yet iterate over steps, well...
#       Also, we want to set more than just the full description

profile="${1:-minimal}"

set -euo pipefail
IFS=$'\n\t'

# Prepare description values
dh_repo=$(dockerhub_repo "${profile}")

readme_filepath=${README_FILEPATH:="./README.md"}
readme_profile_filepath="${readme_filepath}_${profile}"

# Patch README so it
#  - links to Github project and license,
#  - mentions the profile, and
#  - resolves relative links to Github.
cat > "${readme_profile_filepath}" << BADGES
[![Dockerfile](https://img.shields.io/badge/-Dockerfile%20-blue)](https://github.com/reitzig/texlive-docker/blob/master/Dockerfile)
[![GitHub issues](https://img.shields.io/github/issues/reitzig/texlive-docker)](https://github.com/reitzig/texlive-docker/issues)
[![GitHub license](https://img.shields.io/github/license/reitzig/texlive-docker)](https://github.com/reitzig/texlive-docker/blob/master/LICENSE)

BADGES

sed \
    -e "s/\(# TeXlive Docker Image\)s/\1 (${profile})/" \
    -e '/^\[.\+\]:[[:space:]]\+https:\/\//! s#^\[\(.\+\)\]:[[:space:]]\+\([[:alnum:]]\)#[\1]: https://github.com/'${GITHUB_REPO}'/blob/master/\2#g' \
    "${readme_filepath}" \
    >> "${readme_profile_filepath}"

# Retrieve Github repo information
# TODO: make an action out of this?
curl -siX GET https://api.github.com/repos/${GITHUB_REPO} \
     -o ${CURL_OUT}
process_curl_response || exit 1
gh_description=$(print_curl_response_json | jq -r .description)

# Acquire a login token for the Docker Hub API
echo "Acquire Docker Hub login token"
curl -siX POST https://hub.docker.com/v2/users/login/ \
     -H "Content-Type: application/json" \
     -o ${CURL_OUT} \
     -d @- \
<< PAYLOAD
{
    "username": "${DOCKERHUB_USER_NAME}",
    "password": "${DOCKERHUB_ACCESS_TOKEN}"
}

PAYLOAD

process_curl_response | grep -v token || exit 1
dh_token=$(print_curl_response_json | jq -r .token)

echo "Will try to update the description of ${dh_repo}"
curl -siX PATCH https://hub.docker.com/v2/repositories/${dh_repo}/ \
     -H "Authorization: JWT ${dh_token}" \
     -o ${CURL_OUT} \
     --data-urlencode description=${gh_description} \
     --data-urlencode full_description@${readme_profile_filepath}

# TODO: tags/categories/topics? << Github topics
# TODO: icon?

process_curl_response || exit 1
print_curl_response_json | jq .
