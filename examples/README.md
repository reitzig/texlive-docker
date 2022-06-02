# Examples

All examples share the same basic task:

- compile document [`hello_world.tex`] with
- dependencies given in [`Texlivefile`].

They go about it in different ways in order to showcase the flexibility
of using TeXlive in this way -- and to _specify_ how they should work
for testing.

- [One-off build](one-off-build.sh) -- a single command that builds
  a document from scratch.
- [Complex build](complex-build.sh) -- shows how to use a custom build
  script
- [Repeated build](repeated-build.sh) -- shows how to rebuild a
  document in the same container, potentially making use of temporary
  files (e.g. TikZ externalization).
- [Interactive build](interactive-build.sh) -- shows how to keep a
  TeXlive container alive and interact freely with it using `docker cp`
  and `docker exec`.
- [Custom image](custom-image.sh) -- shows how do use a custom Docker
  image to cover more specialized requirements such as pinning versions
  of TeXlive packages. If you need reproducible and/or archive builds,
  look here.

These are just a few examples -- you have to full power of Docker and
the Linux running _in_ the container at your disposal. Go nuts!
You may find some ideas in our [demos](../demo).

## How to run the examples

The examples can be run as shell scripts:

```bash
./one-off-build.sh
```

### Note

- The examples are tested to run with
  [`base-luatex`](../profiles/base-luatex.profile)
  images. "Larger" images will also work.
- If you want to try out a custom image, pass its tag to the example:

    ```bash
    ./one-off-build.sh texlive-base-luatex:local-testing
    ```

## How to read the examples

The examples are executable for the purpose of testing.
Some hoop-jumping is necessary to make them run both locally _and_
in CI/CD jobs which, unfortunately, has made them less readable.

Here are some remarks that should help.

- Script [_example_setup.sh] is `source`-ed from the top of each
  script. If defines variables that are then used in the example
  scripts.

  - The first parameter is the name (and tag) of the image used to run
    the example; it is optional with default `reitzig/texlive-base-luatex`.
    It sets variable `$image` to this value.
  - It sets variable `$tty_params` so that `docker run` et al. run
    in both interactive and non-interactive shells.
