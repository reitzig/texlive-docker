#!/usr/bin/env bash

function dockerhub_repo {
    prefix="${DOCKERHUB_USER_NAME:-}${DOCKERHUB_USER_NAME:+/}"
    echo "${prefix}texlive-${1:-minimal}"
}

# Log curl response and confirm success
CURL_OUT="curl_out"
function process_curl_response {
    cat "${CURL_OUT}"
    status_code=$(cat "${CURL_OUT}" | grep -e '^HTTP/' | awk '{ print $2 }')
    [[ ${status_code} =~ 2[0-9]{2} ]]
    return $?
}

function print_curl_response_json {
    # We need to cut off headers; search for first opening brace
    cat "${CURL_OUT}" | sed '/^{/,$!d'
    echo ""
}
