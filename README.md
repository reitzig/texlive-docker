# TeXlive Docker Images

Yet another attempt at coming up with working _and_ generally applicable
Docker images for [TeXlive][texlive].

The basic concept is to provide small-ish base images which
install additional packages from CTAN if and when needed.

These images attempt to cover the following use cases:

 - Replace local TeXlive installations.
 - Build LaTeX documents in CI/CD pipelines.
 - Build legacy documents with old package versions.

We currently publish the following images based on different selections
from the TeXlive collections suggested by [the installer][install-tl]; 
from smaller to larger:

 - [reitzig/texlive-minimal][minimal-dockerhub] ([profile][minimal-profile])
 - [reitzig/texlive-base][base-dockerhub] ([profile][base-profile])
 - [reitzig/texlive-base-luatex][base-luatex-dockerhub] ([profile][base-luatex-profile])
 - [reitzig/texlive-base-xetex][base-xetex-dockerhub] ([profile][base-xetex-profile])
 - [reitzig/texlive-full][full-dockerhub] ([profile][full-profile])

We also provide PoCs to demonstrate that more involved applications can
be built on top of the base images provided here:
 
 - [Serve a static set of pre-built documents.][demo-static-serve]
 <!-- TODO - LaTeX CI pipeline -->
 <!-- TODO - LaTeX build server. -->
 <!-- TODO - Document generation server. -->


## Usage

The fastest way to build a document at hand (once) is this:

```bash
docker run --rm \
    --volume `pwd`:/work/src:ro \
    --volume `pwd`/out:/work/out \
    reitzig/texlive-base-luatex \
    work 'lualatex hello_world.tex'
```

Note:

 - This assumes that all TeXlive packages beyond what is contained in the
   `texlive-base-luatex` image are listed in `Texlivefile`.
   You can also use image `reitzig/texlive-full` instead if you are happy
   with downloading a (way) larger image.
 - This may overwrite files in `out`. Chose a folder name that you currently
   do not use.

See the scripts in [`examples`][examples] for other ways to use the images.
<!-- TODO: document properly -->

### Dependencies

Place a file called `Texlivefile`  with a list of required CTAN packages, 
one name per line, in the source directory. 
The container will install all packages on that list before running the work command.

### Parameters

You can adjust some defaults of the 
    [main container script][entrypoint]
by 
    [setting environment variables][docker-set-env]
 
 - `BUILDSCRIPT` (default: `build.sh`)  
   If present, the given script will be executed unless a work command is specified.
 - `TEXLIVEFILE` (default: `Texlivefile`)  
   The file to read dependencies from.
 - `OUTPUT` (default: `*.pdf *.log`)  
   Shell pattern for all files that should be copied from the working to the output directory.

### Debugging

All output of the work command is collected in a single folder; extract it with:

    docker cp $container:/work/tmp ./


## Build

Run

    docker build -t texlive-base-luatex --build-arg "profile=base-luatex" .

to build an image locally. Exchange `base-luatex` for any of the profile names in
[`profiles`][profiles] to start from another baseline.

### Customization

If you repeatedly need the same exact set of dependencies or even sources, it
might make sense to create your own TeXlive Docker image.
There are two ways to go about that:

 - Extend one of the existing images using your own Dockerfile (see [example][custom-dockerfile]);
   install additional TeXlive (or even Alpine) packages, copy source files
   or additional scripts into the appropriate folders, fix the work command, or ...
    
 - Use [install-tl][install-tl] to create your own TeXlive installation profile. Make sure to
 
    1. select platform `x86_64-linuxmusl` and
    2. manually change line `binary_x86_64-linux 1` in the resulting profile file
       to `binary_x86_64-linux 0`.
       <!-- Yup, it's a workaround; musl-only installs are apparently not well-supported.
            See a matching note in Dockerfile. Any advice is appreciated. -->
   
   If you want to use your profile across different TeXlive versions,
   replace all occurrences of the TeXlive version (e.g. `2019`) with `${tlversion}`.
       
   Copy the final file to [`profiles`][profiles] and run the regular build command.
   

<!-- Note: Repo-relative links will be rewritten by update-dockerhub-info.sh before pushing to Docker Hub -->
[examples]: examples
[profiles]: profiles
[entrypoint]: entrypoint.sh
[custom-dockerfile]: examples/Dockerfile
[demo-static-serve]: demo/static-document-server

[minimal-dockerhub]: https://hub.docker.com/r/reitzig/texlive-minimal
[minimal-profile]: profiles/minimal.profile
[base-dockerhub]: https://hub.docker.com/r/reitzig/texlive-base
[base-profile]: profiles/base.profile
[base-luatex-dockerhub]: https://hub.docker.com/r/reitzig/texlive-base-luatex
[base-luatex-profile]: profiles/base-luatex.profile
[base-xetex-dockerhub]: https://hub.docker.com/r/reitzig/texlive-base-xetex
[base-xetex-profile]: profiles/base-xetex.profile
[full-dockerhub]: https://hub.docker.com/r/reitzig/texlive-full
[full-profile]: profiles/full.profile

[docker-set-env]: https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file
[install-tl]: https://www.tug.org/texlive/acquire-netinstall.html
[texlive]: https://www.tug.org/texlive/
