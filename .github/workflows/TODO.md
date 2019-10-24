### Build
 - Add version as build parameter/environment variable/label

    - Set `$version` to `$tl.$c`
        - `$tl`: TeXlive release
         
              docker run --rm $image version | head -n 1 | awk '{ print $5 }'
        - `$c`: increasing counter
    - Tag Git revision `release-$tl.$c`
    - For each profile,
        - build (from scratch)
        - run a small test
        - push to Dockerhub as `texlive-$profile:{$version,$git-tag,latest}`
    - create Github release

### Trigger 
 - Scheduled: once a month (?)
 - Tag push: add Docker tag `$git_tag`
