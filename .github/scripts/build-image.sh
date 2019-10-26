#!/usr/bin/env bash

set -eu

image_tag_list="${IMAGE_TAG_LIST:-/dev/stdout}"

ref="${1}"
profile="${2:-minimal}"
commit_time="$(date --date=@$(git show -s --format=%ct HEAD) --rfc-3339=seconds)"
    # Use commit time for (more) reproducible builds; format is required by OCI annotation spec.

function make_docker_tag {
    echo "reitzig/texlive-${1}:${2}"
}

case "${ref}" in
    ref/tags/release-* )
        version="${ref##*/release-}"
        docker build \
            --tag "$(make_docker_tag ${profile} ${version})" \
            --tag "$(make_docker_tag ${profile} latest)" \
            --build-arg "profile=${profile}" \
            --build-arg "label_created=${commit_time}" \
            --build-arg "label_version=${version}" \
            --build-arg "label_tlversion=${version%.*}" \
            --build-arg "label_revision=$(git rev-parse --verify HEAD)" \
            .
        make_docker_tag ${profile} ${version} >> ${image_tag_list}
        make_docker_tag ${profile} latest >> ${image_tag_list}
        ;;
    ref/tags/pre-* )
        version="${ref##*/pre-}"
        docker build --no-cache \
            --tag $(make_docker_tag ${profile} ${version}) \
            --build-arg "profile=${profile}" \
            --build-arg "label_created=${commit_time}" \
            --build-arg "label_version=${version}" \
            --build-arg "label_revision=$(git rev-parse --verify HEAD)" \
            .
        make_docker_tag ${profile} ${version} >> ${image_tag_list}
        ;;
    * )
        version="${ref##*/}"
        # This is testing, just build the thing.
        docker build --no-cache \
            --tag $(make_docker_tag ${profile} ${version}) \
            --build-arg "profile=${profile}" \
            .
        make_docker_tag ${profile} ${version} >> ${image_tag_list}
        ;;
esac
