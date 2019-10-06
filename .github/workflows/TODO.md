 - Add version as build parameter/environment variable/label
 - For each profile,
    - build (from scratch)
    - run a small test
    - publish to Dockerhub: texlive-$profile:{version,latest}

 - Timed trigger: build new version once a month (?)
    - set new version number
    - Main version: from installer archive
    - Minor version: month? count?