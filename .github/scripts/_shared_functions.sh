#!/usr/bin/env bash

function dockerhub_repo {
    prefix="${DOCKERHUB_USER_NAME:-}${DOCKERHUB_USER_NAME:+/}"
    echo "${prefix}texlive-${1:-minimal}"
}

# Log curl response and confirm success
CURL_OUT="curl_out"
function process_curl_response {
    cat "${CURL_OUT}"
    status_code=$(grep -e '^HTTP/' "${CURL_OUT}" | awk '{ print $2 }')
    [[ ${status_code} =~ 2[0-9]{2} ]]
    return $?
}

function print_curl_response_json {
    # We need to cut off headers; search for first opening brace
    sed '/^{/,$!d' "${CURL_OUT}"
    echo ""
}

mirrors_to_avoid=(
    "https://us.mirrors.cicku.me/ctan/" # repeatedly failed builds because the update 2025->2026 was tardy
)

function choose_ctan_mirror() {
    retries_left="${1:-5}"

    # Can't seem to resolve mirrors.ctan.org from within 'docker build', so do it up front.
    # Sticking to a single mirror may also be a good idea for consistency
    ctan_mirror="$(curl -Ls -o /dev/null -w '%{url_effective}' https://mirrors.ctan.org)"

    if ! [[ ${mirrors_to_avoid[*]} =~ ${ctan_mirror} ]]; then
        echo "${ctan_mirror}"
    elif (( retries_left > 0 )); then
        # retry
        choose_ctan_mirror $((retries_left - 1))
    else
        echo "Couldn't find a suitable mirror; aborting"
        exit 1
    fi
}
