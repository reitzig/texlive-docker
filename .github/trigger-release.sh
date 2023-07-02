#!/usr/bin/env bash

# TODO: Obsolete? Can trigger Workflow from web UI these days.

set -eu

read -sp "Github API Token: " ght
echo ""

curl -siX POST https://api.github.com/repos/reitzig/texlive-docker/dispatches \
    -H "Authorization: token ${ght}" \
    -H "Accept: application/vnd.github.everest-preview+json" \
    --data '{"event_type": "manual-release"}'
