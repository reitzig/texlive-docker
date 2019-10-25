# TeXlive Docker Images

Yet another attempt at coming up with working _and_ generally applicable
Docker images for 
    [TeXlive](https://www.tug.org/texlive/).

The basic concept is to provide small-ish base images which
install additional packages from CTAN if and when needed.

These images attempt to cover the following use cases:

 - Replace local TeXlive installations.
 - Build LaTeX documents in CI/CD pipelines.
 - Build legacy documents with old package versions.
 
We also include PoCs to demonstrate that more involved applications can
be built on top of the base images provided here:
 
 - [Serve a static set of pre-built documents.](demo/static-document-server)
 <!-- - LaTeX build server. -->
 <!-- - Document generation server. -->


## Build

Run

    docker build -t texlive-base-luatex --build-arg "profile=base-luatex" .

to build an image locally.
Exchange `base-luatex` for any of the profile names in
    [`profiles`](profiles)
to start from another baseline.
<!-- TODO: build in Actions and deploy to registry; adapt doc -->


## Usage

See the scripts in 
    [`example`](example)
for different ways to use the images.
<!-- TODO: document properly -->

### Dependencies

Place a file called `Texlivefile`  with a list of required CTAN packages, 
one name per line, in the source directory. 
The container will install all packages on that list before running the work command.

### Parameters

You can adjust some defaults of the 
    [main container script](entrypoint.sh)
by 
    [setting environment variables](https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file):
 
 - `BUILDSCRIPT` (default: `build.sh`)  
   If present, the given script will be executed unless a work command is specified.
 - `TEXLIVEFILE` (default: `Texlivefile`)  
   The file to read dependencies from.
 - `OUTPUT` (default: `*.pdf *.log`)  
   Shell pattern for all files that should be copied from the working to the output directory.


### Debugging

All output of the work command is collected in a single folder; extract it with:

    docker cp $container:/work/tmp ./


<!-- ## Customization

Custom profile -> docker build --build-arg "profile=foo"  ( !! note hacks !! )
     FROM + RUN tlmgr install 
     FROM + ... + COPY _ ${SRC_DIR}

<!-- TODO: CI/CD -> ENTRYPOINT + CMD 
<!-- TODO: Server? -->
