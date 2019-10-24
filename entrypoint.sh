#!/usr/bin/env bash

set -eu

command="${1:-}"

case "${command}" in
    "" | "help" )
        echo "Help!" # TODO: useful output
        ;;
    "hold" )
        echo "Blocking to keep container alive"
        tail -f /dev/null
        ;;
    "clean" )
        rm -rf "${TMP_DIR:?}"/*
        ;;
    "work" ) # Just because 'run' and 'exec' are Docker keywords
        case "${2:-}" in
            "" )
                if [[ -f "${SRC_DIR}/${BUILDSCRIPT}" ]]; then
                    work_command="${SRC_DIR}/${BUILDSCRIPT}"
                else
                    echo 'Neither work command or build script given.'
                    exit 1
                fi
                ;;
            *)
                work_command="${2}"

                if [[ -f "${SRC_DIR}/${BUILDSCRIPT}" ]]; then
                    echo "Work command overrides build script ${BUILDSCRIPT}."
                fi
            ;;
        esac

        # Install dependencies
        hashfile="${TMP_DIR}/${TEXLIVEFILE}.sha"
        if [[ -f "${SRC_DIR}/${TEXLIVEFILE}" ]]; then
            if ! sha256sum -c "${hashfile}" > /dev/null 2>&1; then
                echo "Installing dependencies ..."
                xargs tlmgr install < "${SRC_DIR}/${TEXLIVEFILE}"
                sha256sum "${SRC_DIR}/${TEXLIVEFILE}" > "${hashfile}"
            else
                echo "${TEXLIVEFILE} has not changed; nothing new to install."
            fi
        else
            echo "${TEXLIVEFILE} not found; continuing without installing additional packages."
        fi
        echo ""

        # Execute command on (per se uncleaned) copy
        cp -rf "${SRC_DIR}"/* "${TMP_DIR}"/
        cd "${TMP_DIR}"
        rm -f ${OUTPUT}
        bash -c "${work_command}" || true q

        # Copy output to final destination
        cp ${OUTPUT} "${OUT_DIR}"/
        ;;
    *)
        echo "Unknown command '${command}'"
        exit 1
        ;;
esac
