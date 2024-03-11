FROM alpine:3.18@sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978 AS texlive-installer

# renovate: datasource=repology depName=alpine_3_18/bash versioning=loose
ENV BASH_VERSION="5.2.15-r5"
# renovate: datasource=repology depName=alpine_3_18/cairo versioning=loose
ENV CAIRO_VERSION="1.17.8-r1"
# renovate: datasource=repology depName=alpine_3_18/icu versioning=loose
ENV ICU_LIBS_VERSION="73.2-r2"
# renovate: datasource=repology depName=alpine_3_18/gcc versioning=loose
ENV LIBGCC_VERSION="12.2.1_git20220924-r10"
# renovate: datasource=repology depName=alpine_3_18/libpaper versioning=loose
ENV LIBPAPER_VERSION="2.1.1-r0"
# renovate: datasource=repology depName=alpine_3_18/libpng versioning=loose
ENV LIBPNG_VERSION="1.6.39-r3"
# renovate: datasource=repology depName=alpine_3_18/gcc versioning=loose
ENV LIBSTDCPP_VERSION="12.2.1_git20220924-r10"
# renovate: datasource=repology depName=alpine_3_18/libx11 versioning=loose
ENV LIBX11_VERSION="1.8.7-r0"
# renovate: datasource=repology depName=alpine_3_18/musl versioning=loose
ENV MUSL_VERSION="1.2.4-r2"
# renovate: datasource=repology depName=alpine_3_18/perl versioning=loose
ENV PERL_VERSION="5.36.2-r0"
# renovate: datasource=repology depName=alpine_3_18/pixman versioning=loose
ENV PIXMAN_VERSION="0.42.2-r1"
# renovate: datasource=repology depName=alpine_3_18/wget versioning=loose
ENV WGET_VERSION="1.21.4-r0"
# renovate: datasource=repology depName=alpine_3_18/xz versioning=loose
ENV XZ_VERSION="5.4.3-r0"
# renovate: datasource=repology depName=alpine_3_18/zlib versioning=loose
ENV ZLIB_VERSION="1.2.13-r1"
RUN apk --no-cache add \
    bash=${BASH_VERSION} \
    cairo=${CAIRO_VERSION} \
    icu-libs=${ICU_LIBS_VERSION} \
    libgcc=${LIBGCC_VERSION} \
    libpaper=${LIBPAPER_VERSION} \
    libpng=${LIBPNG_VERSION} \
    libstdc++=${LIBSTDCPP_VERSION} \
    libx11=${LIBX11_VERSION} \
    musl=${MUSL_VERSION} \
    perl=${PERL_VERSION} \
    pixman=${PIXMAN_VERSION} \
    wget=${WGET_VERSION} \
    xz=${XZ_VERSION} \
    zlib=${ZLIB_VERSION}

ARG ctan_mirror="https://mirrors.ctan.org"
ENV CTAN_MIRROR=$ctan_mirror

RUN wget "${CTAN_MIRROR}/systems/texlive/tlnet/install-tl-unx.tar.gz" \
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

ARG ctan_mirror="https://mirrors.ctan.org"
ENV CTAN_MIRROR=$ctan_mirror

RUN (  cd install-tl \
    && tlversion=$(cat release-texlive.txt | head -n 1 | awk '{ print $5 }') \
    && sed -i "s/\${tlversion}/${tlversion}/g" ${profile}.profile \
    && ./install-tl -repository="${CTAN_MIRROR}/systems/texlive/tlnet" -profile ${profile}.profile \
 ) \
 && rm -rf install-tl \
 && tlmgr version | tail -n 1 > version \
 && echo "Installed on $(date)" >> version
 # && tlmgr option repository "${CTAN_MIRROR}"
 # TODO: Determine if this is necessary -- shouldn't be, and
 #       we don't want to hammer the same mirror whenever the image is used!

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
