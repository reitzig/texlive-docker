#!/bin/bash

set -eu

command="${1:-}"

case "${command}" in
    "" | "help" )
        echo "Help!" # TODO: useful output
        ;;
    "clean" )
        rm -rf "${TMP_DIR:?}"/*
        ;;
    "work" ) # Just because 'run' and 'exec' are Docker keywords
        work_command=${2:-echo 'Empty work command'}

        # Install dependencies
        if [[ -f "${SRC_DIR}/${TEXLIVEFILE}" ]]; then
            # TODO: Do only if hash changed
            xargs tlmgr install < "${SRC_DIR}/${TEXLIVEFILE}"
        else
            echo "Texlivefile not found; continuing without installing additional packages."
        fi

        # Execute command on (per se uncleaned) copy
        cp -rf "${SRC_DIR}"/* "${TMP_DIR}"/
        cd "${TMP_DIR}"
        bash -c "${work_command}" || true q

        # Copy output to final destination
        cp ${OUTPUT} "${OUT_DIR}"/
        ;;
    *)
        echo "Unknown command '${command}'"
        exit 1 
        ;;
esac
