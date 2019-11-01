#!/usr/bin/env bash

source "$(dirname $0)/_shared_functions.sh"

installer_image=${TEXLIVE_INSTALLER_IMAGE:-'texlive-installer:latest'}

# Get the TeXlive installer and extract the major version
tlversion="$(docker run --rm "${installer_image}" | head -n 1 | awk '{ print $5 }')"

# Check if this version was released before
set -o pipefail
last_minor_version="$(git tag | grep release-${tlversion}. | sed -e "s/release-${tlversion}\.//" | sort -rn | head -n 1)"

if [[ $? -eq 0 ]]; then
    # Increment "minor version"
    next_version="${tlversion}.$(($last_minor_version + 1))"
else
    # No tag for this TeXlive version yet, start over
    next_version="${tlversion}.1"
fi

# POST a new tag via Github API
current_commit="$(git show-ref master --hash | head -n 1)"
new_tag="release-${next_version}"
echo "Will try to create tag ${new_tag} on ${GITHUB_REPOSITORY}:${current_commit}"

# First, create the tag _object_ (for the annotation)
# cf. https://developer.github.com/v3/git/tags/#create-a-tag-object
curl -siX POST https://api.github.com/repos/${GITHUB_REPOSITORY}/git/tags \
     -H "Authorization: token ${GITHUB_TOKEN}" \
     -o ${CURL_OUT} \
     -d @- \
<< PAYLOAD
{
  "tag": "${new_tag}",
  "message": "Scheduled re-release.\n",
  "object": "${current_commit}",
  "type": "commit",
  "tagger": {
    "name": "Raphael Reitzig",
    "email": "4246780+reitzig@users.noreply.github.com",
    "date": "$(date --iso-8601=seconds)"
  }
}

PAYLOAD

process_curl_response || exit 1

# Now, create the tag _reference_ (to have an actual Git tag)
# cf. https://developer.github.com/v3/git/refs/#create-a-reference
curl -siX POST https://api.github.com/repos/${GITHUB_REPOSITORY}/git/refs \
     -H "Authorization: token ${GITHUB_TOKEN}" \
     -o ${CURL_OUT} \
     -d @- \
<< PAYLOAD
{
  "ref": "refs/tags/${new_tag}",
  "sha": "${current_commit}"
}
PAYLOAD

process_curl_response || exit 1
