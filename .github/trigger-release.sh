#!/usr/bin/env bash

set -eu

read -sp "Github API Token: " ght
echo ""

curl -siX POST https://api.github.com/repos/reitzig/texlive-docker/dispatches \
    -H "Authorization: token ${ght}" \
    -H "Accept: application/vnd.github.everest-preview+json" \
    --data '{"event_type": "manual-release"}'
