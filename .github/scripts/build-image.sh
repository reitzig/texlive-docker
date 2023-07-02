#!/usr/bin/env bash

source "$(dirname "${0}")/_shared_functions.sh"

set -eu

installer_image=${TEXLIVE_INSTALLER_IMAGE:-'texlive-installer:latest'}
image_tag_list="${IMAGE_TAG_LIST:-/dev/stdout}"

ref="${1}"
profile="${2:-minimal}"
commit_time="$(date --date="@$(git show -s --format=%ct HEAD)" --rfc-3339=seconds)"
    # Use commit time for (more) reproducible builds; format is required by OCI annotation spec.

tlversion="$(docker run --rm "${installer_image}" | head -n 1 | awk '{print $5 }')"

function make_docker_tag {
    echo "$(dockerhub_repo "${1}"):${2}"
}

case "${ref}" in
    refs/tags/release-* )
        version="${ref##*/release-}"

        # Confirm that release tag and to-be-installed version match
        if [[ ${tlversion} -ne ${version%.*} ]]; then
            echo "TeXlive version mismatch: Installer version ${tlversion} vs Git tag ${ref##*/}"
            exit 77
        fi

        docker build \
            --cache-from "${installer_image}" \
            --tag "$(make_docker_tag "${profile}" "${version}")" \
            --tag "$(make_docker_tag "${profile}" latest)" \
            --build-arg "profile=${profile}" \
            --build-arg "label_created=${commit_time}" \
            --build-arg "label_version=${version}" \
            --build-arg "label_tlversion=${tlversion}" \
            --build-arg "label_revision=$(git rev-parse --verify HEAD)" \
            .
        make_docker_tag "${profile}" "${version}" >> "${image_tag_list}"
        make_docker_tag "${profile}" latest >> "${image_tag_list}"
        ;;
    refs/tags/pre-* )
        version="${ref##*/pre-}"
        docker build \
            --cache-from "${installer_image}" \
            --tag "$(make_docker_tag "${profile}" "${version}")" \
            --build-arg "profile=${profile}" \
            --build-arg "label_created=${commit_time}" \
            --build-arg "label_version=${version}" \
            --build-arg "label_tlversion=${tlversion}" \
            --build-arg "label_revision=$(git rev-parse --verify HEAD)" \
            .
        # shellcheck disable=SC2086
        make_docker_tag "${profile}" "${version}" >> ${image_tag_list}
        ;;
    * )
        version="${ref##*/}"
        # This is testing, just build the thing.
        docker build \
            --cache-from "${installer_image}" \
            --tag "$(make_docker_tag "${profile}" "${version}")" \
            --build-arg "profile=${profile}" \
            .
        make_docker_tag "${profile}" "${version}" >> "${image_tag_list}"
        ;;
esac
