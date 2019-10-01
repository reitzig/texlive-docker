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
 && rm -rf install-tl

ARG src_dir="/work/src"
ARG tmp_dir="/work/tmp"
ARG out_dir="/work/out"
ENV SRC_DIR="${src_dir}"
ENV TMP_DIR="${tmp_dir}"
ENV OUT_DIR="${out_dir}"

VOLUME [ "${src_dir}", "${tmp_dir}", "${out_dir}" ]

COPY entrypoint.sh /bin/entrypoint

# USER ?
WORKDIR /work

ENV TEXLIVEFILE="Texlivefile"
ENV OUTPUT="*.pdf *.log"

ENTRYPOINT [ "/bin/entrypoint" ]
CMD [ "help" ]