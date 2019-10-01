# texlive-docker

## Usage

    OUTPUT=foo.pdf

 Use:
  - bind-mount /work/src, /work/out; docker run ... --work '...'
  - FROM+COPY into /work/src; bind-mount /work/out; docker run ... --work '...'
  - either for src; docker run ... --work '...'; docker cp $container:/work/out/* ./

 Rebuild: docker start -a $name


## Customization

 - CI/CD --> ENTRYPOINT + CMD
 - Server?

 ENV TEXLIVEFILE="Texlivefile"
ENV OUTPUT="*.pdf *.log"s