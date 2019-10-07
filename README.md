# TeXlive Docker Images

Yet another attempt at coming up with working _and_ generally applicable
Docker images for 
    [TeXlive](https://www.tug.org/texlive/).

The basic concept is to provide small-ish base images which
install additional packages from CTAN if and when needed.

These images attempt to cover the following use cases:

 - Replace local TeXlive installation.
 - Build LaTeX documents in CI/CD pipelines.
 <!-- - LaTeX build server. -->
 <!-- - Document generation server. -->


## Build

Run

    docker build -t texlive-base-luatex --build-arg "profile=base-luatex" .

to build an image locally.
Exchange `base-luatex` for any of the profile names in
    [`profiles`](https://github.com/reitzig/texlive-docker/tree/master/profiles)
to start from another baseline.
<!-- TODO: build in Actions and deploy to registry; adapt doc -->


## Usage

See the scripts in 
    [`example`](https://github.com/reitzig/texlive-docker/tree/master/example)
for different ways to use the images.
<!-- TODO: document properly -->
<!-- TODO: Write a small script/program tlcrane to wrap those use cases nicely? -->

### Dependencies

Place a file called `Texlivefile`  with a list of required CTAN packages, 
one name per line, in the source directory. 
The container will install all packages on that list before running the work command.

### Parameters

You can adjust some defaults of the 
    [main container script](https://github.com/reitzig/texlive-docker/blob/master/entrypoint.sh)
by 
    [setting environment variables](https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file):

 - `TEXLIVEFILE` (default: `Texlivefile`)  
   The file to read dependencies from.
 - `OUTPUT` (default: `*.pdf *.log`)  
   Shell pattern for all files that should be copied from the working to the output directory.


### Debugging

All output of the work command is collected in a single folder; extract it with:

    docker cp $container:/work/tmp ./


<!-- ## Customization

Custom profile -> docker build --build-arg "profile=foo" 
     FROM + RUN tlmgr install 
     FROM + ... + COPY _ ${SRC_DIR}

<!-- TODO: CI/CD -> ENTRYPOINT + CMD 
<!-- TODO: Server? -->
