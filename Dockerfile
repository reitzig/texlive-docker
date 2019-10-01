FROM alpine:3.10

RUN apk --no-cache add \
    texlive-luatex \
    texlive-xetex

#RUN apk --no-cache add xz

# Somehow forgotten in the package:
RUN ln -s /usr/bin/luatex /usr/bin/lualatex

# Workaround for packaging bug:
RUN sed -i -e 's#Master/tlpkg#Master/texmf-dist/tlpkg#' /usr/bin/tlmgr

RUN tlmgr init-usertree && tlmgr update --all
# TODO: WIP: errors!

ARG src_dir="/work/src"
ARG tmp_dir="/work/tmp"
ARG out_dir="/work/out"
ENV SRC_DIR="${src_dir}"
ENV TMP_DIR="${tmp_dir}"
ENV OUT_DIR="${out_dir}"

RUN mkdir -p ${src_dir} ${tmp_dir} ${out_dir} 
VOLUME [ ${src_dir}, ${tmp_dir}, ${out_dir} ]

COPY entrypoint.sh /bin/entrypoint

# USER ?
WORKDIR /work

ENV TEXLIVEFILE="Texlivefile"
ENV OUTPUT="*.pdf *.log"

ENTRYPOINT [ "/bin/entrypoint" ]
CMD [ "help" ]