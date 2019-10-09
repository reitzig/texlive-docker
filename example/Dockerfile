FROM texlive-base-luatex

COPY hello_world.tex "${SRC_DIR}/"

RUN tlmgr install amsmath qrcode
# --> faster run!

ENTRYPOINT entrypoint work 'lualatex hello_world.tex' > /dev/null && cat "${OUT_DIR}/hello_world.pdf"
# TODO: If this is a frequent/attractive use case,
#       introduce a silent mode so the default entrypoint
#       can be piped to a file directly
#       ( `... work 'lualatex hello_world.tex && cat ...'`)
#       Or an option that prints the result file? Which?
