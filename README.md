# texlive-docker

Yet another attempt at coming up with a working _and_ useful
Docker image for 
    [TeXlive](https://www.tug.org/texlive/).

The basic concept is to provide a small-ish base image which
installs additional packages from CTAN if and when needed.

This image attempts to cover the following use cases:

 - Replace local TeXlive installation.
 - CI/CD pipelines.
 <!-- - LaTeX build server. -->
 <!-- - Document generation server. -->

## Usage

See `example/one-off-build.sh` for an example.
Note that `Texlivefile` contains a list of required CTAN packages. 

<!-- TODO: document properly -->
<!-- TODO: build in Actions and deploy to registry; adapt doc -->
<!-- TODO: check out https://github.com/dopefishh/itex and  https://ctan.org/pkg/texliveonfly -->

<!-- 
ENV TEXLIVEFILE="Texlivefile"
ENV OUTPUT="*.pdf *.log"

 Use:
  - bind-mount /work/src, /work/out; docker run ... --work '...'
  - FROM+COPY into /work/src; bind-mount /work/out; docker run ... --work '...'
  - either for src; docker run ... --work '...'; docker cp $container:/work/out/* ./

 Rebuild: docker start -a $name
 -->

### Debugging

All output of the command you ran is collected in a single folder; extract it with:

    docker cp $container:/work/tmp ./


## Customization

<!-- Custom profile -> docker build --build-arg "profile=foo" -->
<!-- FROM + RUN tlmgr install -->

<!-- TODO: CI/CD -> ENTRYPOINT + CMD -->
<!-- TODO: Server? -->