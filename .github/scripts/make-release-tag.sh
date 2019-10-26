#!/usr/bin/env bash

installer_image=${TEXLIVE_INSTALLER_IMAGE:-'texlive-installer:latest'}

# Get the TeXlive installer and extract the major version
tlversion="$(docker run --rm "${installer_image}" | head -n 1 | awk '{print $5 }')"

# Check if this version was released before
set -o pipefail
last_tag="$(git tag | grep release-${tlversion}. | sort -rh | head -n 1)"

if [[ $? -eq 0 ]]; then
    # Increment "minor version"
    last_minor_version="${last_tag#release-${tlversion}.}"
    next_version="${tlversion}.$(($last_minor_version + 1))"
else
    # No tag for this TeXlive version yet, start over
    next_version="${tlversion}.1"
fi

# POST a new tag via Github API
repo="$(git remote -v | grep origin | head -n 1 | sed -e 's#^.*github.com[:/]\([^\.]*\)\([[:space:]]\|\.git\).*$#\1#')"
    # fugly regexp to cover both HTTP and SSH remotes
current_commit="$(git show-ref master --hash | head -n 1)"
new_tag="release-${next_version}"
echo "Will try to create tag ${new_tag} on ${repo}:${current_commit}"

# Log response and confirm success
function process_response {
    cat curl_out
    status_code=$(cat curl_out | grep Status: | awk '{ print $2 }')
    [[ ${status_code} =~ 2[0-9]{2} ]]
    return $?
}

# First, create the tag _object_ (for the annotation)
# cf. https://developer.github.com/v3/git/tags/#create-a-tag-object
curl -siX POST https://api.github.com/repos/${repo}/git/tags \
     -H "Authorization: token ${GITHUB_TOKEN}" \
     -o curl_out \
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

process_response || exit 1

# Now, create the tag _reference_ (to have an actual Git tag)
# cf. https://developer.github.com/v3/git/refs/#create-a-reference
curl -siX POST https://api.github.com/repos/${repo}/git/refs \
     -H "Authorization: token ${GITHUB_TOKEN}" \
     -o curl_out \
     -d @- \
<< PAYLOAD
{
  "ref": "refs/tags/${new_tag}",
  "sha": "${current_commit}"
}
PAYLOAD

process_response || exit 1
