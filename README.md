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

We also provide PoCs to demonstrate that more involved applications can
be built on top of the base images provided here:

- [Serve a static set of pre-built documents.][demo-static-serve]
<!-- TODO - devcontainers -->
<!-- TODO - LaTeX CI pipeline: https://github.com/reitzig/dh-tools -->
<!-- TODO - LaTeX build server. -->
<!-- TODO - Document generation server. -->

## Usage

The fastest way to build a document at hand (once) is this:

```bash
docker run --rm \
    --volume `pwd`:/work/src:ro \
    --volume `pwd`/out:/work/out \
    reitzig/texlive-base-luatex \
    work lualatex hello_world.tex
```

Note:

- This assumes that all TeXlive packages beyond what is contained in the
  `texlive-base-luatex` image are listed in `Texlivefile`.
  You can also use image `reitzig/texlive-full` instead if you are happy
  with downloading a (way) larger image.
- This may overwrite files in `out`. Chose a folder name that you currently
  do not use.

See the scripts in [`examples`][examples] for other ways to use the images.

### Dependencies

Place a file called `Texlivefile`  with a list of required CTAN packages,
one name per line, in the source directory.
The container will install all packages on that list before running the work command.

---
⚠️ Images will stop working once a new version of TeXlive is released with an error like this:

> tlmgr: Local TeX Live (2023) is older than remote repository (2024).

If you need to keep using an older image for a little while, 
you can override the repository by setting environment variable 
`TEXLIVE_REPOSITORY` to a value like
```
https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2023/tlnet-final
```
This feature has been available since 2024.1;
see 
  [reitzig/texlive-docker#18](https://github.com/reitzig/texlive-docker/issues/18)
for hints on how to backport it to older images.

⚠️ Note that most CTAN mirrors do not maintain historic versions
(cf. [tex.SE#460132](https://tex.stackexchange.com/questions/460132/historic-tex-live-distributions-https-sftp-mirror)),
so keep in mind that widespread use of this workaround _will_ stress those few mirrors who do.
We strongly recommend upgrading to the latest TeXlive version as soon as possible!

<!-- TODO: provide example-->
<!-- ℹ️ That said, an alternative is to maintain custom Docker images with historic package versions;
see [here](TODO) for an example. -->

---

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

```bash
docker cp $container:/work/tmp ./
```

## Build

Run

```bash
docker build -t texlive-base-luatex --build-arg "profile=base-luatex" .
```

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

[docker-set-env]: https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file
[install-tl]: https://www.tug.org/texlive/acquire-netinstall.html
[texlive]: https://www.tug.org/texlive/
