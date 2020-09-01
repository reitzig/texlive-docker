#!/usr/bin/env bash

set -eu

curl -siX POST https://api.github.com/repos/reitzig/texlive-docker/dispatches \
    -H "Authorization: token ${GHT}" \
    -H "Accept: application/vnd.github.everest-preview+json" \
    --data '{"event_type": "manual-release"}'
