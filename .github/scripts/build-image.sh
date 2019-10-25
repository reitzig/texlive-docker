#!/usr/bin/env bash

set -u

tag="${1}"
profile="${2:-minimal}"
commit_time="$(date --date=@$(git show -s --format=%ct HEAD) --rfc-3339=seconds)"
    # Use commit time for (more) reproducible builds; format is required by OCI annotation spec.

case "${tag}" in
    release-* )
        version="${tag#release-}"
        docker build \
            --tag reitzig/texlive-${profile}:${version} \
            --tag reitzig/texlive-${profile}:latest \
            --build-arg "profile=${profile}" \
            --build-arg "label_created=${commit_time}" \
            --build-arg "label_version=${version}" \
            --build-arg "label_tlversion=${version%.*}" \
            --build-arg "label_revision=$(git rev-parse --verify HEAD)" \
            .
        ;;
    pre-* )
        version="${tag#pre-}"
        docker build --no-cache \
            --tag reitzig/texlive-${profile}:${version} \
            --build-arg "profile=${profile}" \
            --build-arg "label_created=${commit_time}" \
            --build-arg "label_version=${version}" \
            --build-arg "label_revision=$(git rev-parse --verify HEAD)" \
            .
        ;;
    * )
        # This is testing, just build the thing.
        docker build --no-cache \
            --tag texlive-${profile}:${tag} \
            --build-arg "profile=${profile}" \
            .
        ;;
esac
