FROM alpine:3.10 AS texlive-installer

RUN apk --no-cache add \
    bash=5.0.0-r0 \
    cairo=1.16.0-r2 \
    icu-libs=64.2-r1 \
    libgcc=8.3.0-r0 \
    libpaper=1.1.26-r0 \
    libpng=1.6.37-r1 \
    libstdc++=8.3.0-r0 \
    libx11=1.6.8-r1 \
    musl=1.1.22-r3 \
    perl=5.28.3-r0 \
    pixman=0.38.4-r0 \
    wget=1.20.3-r0 \
    xz=5.2.4-r0 \
    zlib=1.2.11-r1

RUN wget mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz \
 && tar -xzf install-tl-unx.tar.gz \
 && rm install-tl-unx.tar.gz \
 && mv install-tl-* install-tl

ENTRYPOINT cat install-tl/release-texlive.txt
    # Only used in `make-release-tag.sh`, overwritten for final image below

# # # # # # # # # # # # # # #
# Re-use the installer image -- built only once during CI/CD!
#  cf. build-image.sh
FROM texlive-installer AS texlive

ARG profile=minimal
COPY "profiles/${profile}.profile" /install-tl/${profile}.profile

# Workaround: installer doesn't seem to handle linuxmusl(-only) install correctly
RUN tlversion=$(cat install-tl/release-texlive.txt | head -n 1 | awk '{ print $5 }') \
 && mkdir -p /usr/local/texlive/${tlversion}/bin \
 && ln -s /usr/local/texlive/${tlversion}/bin/x86_64-linuxmusl /usr/local/texlive/${tlversion}/bin/x86_64-linux \
 && ln -s /usr/local/texlive/${tlversion}/bin/x86_64-linuxmusl/mktexlsr /usr/local/bin/mktexlsr

RUN (  cd install-tl \
    && tlversion=$(cat release-texlive.txt | head -n 1 | awk '{ print $5 }') \
    && sed -i "s/\${tlversion}/${tlversion}/g" ${profile}.profile \
    && ./install-tl -profile ${profile}.profile \
 ) \
 && rm -rf install-tl \
 && tlmgr version | tail -n 1 > version \
 && echo "Installed on $(date)" >> version

ARG src_dir="/work/src"
ARG tmp_dir="/work/tmp"
ARG out_dir="/work/out"
ENV SRC_DIR="${src_dir}"
ENV TMP_DIR="${tmp_dir}"
ENV OUT_DIR="${out_dir}"

# Instead of VOLUME, which breaks multi-stage builds:
RUN mkdir -p "${src_dir}" "${tmp_dir}" "${out_dir}"

COPY entrypoint.sh /bin/entrypoint
# Add "aliases" to align `docker run` and `docker exec` usage.
RUN set -eo noclobber; \
    for cmd in help version hold clean work; do \
        echo -e "#!/bin/sh\n\nentrypoint ${cmd} \"\${@}\"" > /bin/${cmd}; \
        chmod +x /bin/${cmd}; \
    done

WORKDIR /work
ENV BUILDSCRIPT="build.sh"
ENV TEXLIVEFILE="Texlivefile"
ENV OUTPUT="*.pdf *.log"

# Labels as per OCI annotation spec
# cf. https://github.com/opencontainers/image-spec/blob/master/annotations.md (Oct 2019)
ARG label_maintainer="Raphael Reitzig"
ARG label_github="https://github.com/reitzig/texlive-docker"
ARG label_created="nA"
ARG label_version="nA"
ARG label_tlversion=""
ARG label_revision="nA"
LABEL org.opencontainers.image.created="${label_created}" \
      org.opencontainers.image.authors="${label_maintainer}" \
      org.opencontainers.image.url="${label_github}" \
      org.opencontainers.image.documentation="${label_github}" \
      org.opencontainers.image.source="${label_github}" \
      org.opencontainers.image.version="${label_version}" \
      org.opencontainers.image.revision="${label_revision}" \
      org.opencontainers.image.vendor="${label_maintainer}" \
      org.opencontainers.image.licenses="Apache-2.0" \
      # org.opencontainers.image.ref.name -- doesn't apply
      org.opencontainers.image.title="TeXlive ${label_tlversion} (${profile})"
      # org.opencontainers.image.description -- not much more to tell

# TODO: ONBUILD to install additional packages?

STOPSIGNAL SIGKILL
ENTRYPOINT [ "/bin/entrypoint" ]
CMD [ "help" ]
