FROM alpine:3.10

RUN apk --no-cache add \
    bash \
    cairo \
    icu-libs \
    libgcc \
    libpaper \
    libpng \
    libstdc++ \
    libx11 \
    musl \
    perl \
    pixman \
    wget \
    xz \
    zlib

RUN wget mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz \
 && tar -xzf install-tl-unx.tar.gz \
 && rm install-tl-unx.tar.gz \
 && mv install-tl-* install-tl

ARG profile=minimal
COPY "profiles/${profile}.profile" /install-tl/texlive.profile

# Workaround: installer doesn't seem to handle linuxmusl(-only) install correctly
RUN mkdir -p /usr/local/texlive/2019/bin \
 && ln -s /usr/local/texlive/2019/bin/x86_64-linuxmusl /usr/local/texlive/2019/bin/x86_64-linux \
 && ln -s /usr/local/texlive/2019/bin/x86_64-linuxmusl/mktexlsr  /usr/local/bin/mktexlsr

RUN (cd install-tl; ./install-tl -profile texlive.profile) \
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
