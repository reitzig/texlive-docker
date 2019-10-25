#!/usr/bin/env bash

tlversion="$(docker build -t texlive-minimal:tmp --build-arg "profile=minimal" . &> /dev/null \
          && docker run --rm texlive-minimal:tmp version | head -n 1 | awk '{print $5 }' \
          ;  docker rmi texlive-minimal:tmp &> /dev/null)"

set -o pipefail
last_tag="$(git tag | grep release-${tlversion}. | sort -rh | head -n 1)"

if [[ $? -eq 0 ]]; then
    # Increment "minor version"
    last_minor_version="${last_tag#release-${tlversion}.}"
    next_version="${tlversion}.$(($last_minor_version + 1))"
else
    # No tag for this TeXlive version yet
    next_version="${tlversion}.1"
fi

repo="$(git remote -v | grep origin | head -n 1 | sed -e 's/^.*github.com:\(.*\)\.git.*$/\1/')"
current_commit="$(git show-ref refs/heads/master --hash)"
new_tag="release-${next_version}"

# POST a new ref to repo via Github API
curl    -s -X POST https://api.github.com/repos/reitzig/texlive-docker/git/refs \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -d @- << EOF
{
  "ref": "refs/tags/${new_tag}",
  "sha": "${current_commit}"
}
EOF
