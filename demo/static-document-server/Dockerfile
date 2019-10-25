ARG out_dir="/work/out"
# This is needed to all stages agree about the output directory

# build base image with:
#   docker build -t texlive-base-luatex --build-arg "profile=base-luatex" .
FROM texlive-base-luatex AS build

COPY . "${SRC_DIR}/"
ENV BUILDSCRIPT="create_many_documents.sh"
RUN work

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

FROM nginx:alpine AS serve
ARG out_dir

# Enable the auto index page
RUN sed -i -e '/location.*\/.*{/a autoindex on\;' /etc/nginx/conf.d/default.conf \
 && rm /usr/share/nginx/html/*

COPY --from=build \
    ${out_dir}/*.pdf \
    /usr/share/nginx/html/

RUN ls -R /usr/share/nginx/html
