#!/usr/bin/env bash

set -eu

command="${1:-}"

documentation="$(cat <<-HELP

Usage: docker exec CONTAINER COMMAND [ARG]

Entrypoint script of TeXlive Docker containers.

Commands:

    clean           Remove all files in TMP_DIR.
    help            Print this message.
    hold            Halt execution and wait for interrupt, keeping container
                    alive.
    version         Print information about the TeXlive version installed in
                    CONTAINER.
    work [STRING]   If given, interprets STRING as Bash command. Otherwise,
                    BUILDSCRIPT is run as work command.
                    Execution proceeds as follows.

                        1. Install dependencies listed in TEXLIVEFILE.
                        2. Copy content of SRC_DIR to TMP_DIR.
                        3. Delete files matching OUTPUT from TMP_DIR.
                        4. Execute work command in TMP_DIR.
                        5. Copy files matching OUTPUT from TMP_DIR to OUT_DIR.

                    Note how the command is not per se idempotent since TMP_DIR
                    is not cleaned after each run.


Environment Variables:

    OUT_DIR         Directory for the relevant output of work commands.
                    Default: /work/out
    SRC_DIR         Directory with project sources. Can be read-only.
                    Default: /work/src
    TMP_DIR         The working directory for work commands.
                    Default: /work/tmp
    BUILDSCRIPT     Script in SRC_DIR that can be run by the work command.
                    Default: build.sh
    TEXLIVEFILE     A file in SRC_DIR that contains the TeXlive packages the
                    project requires, one package name per line.
                    Default: Texlivefile
    OUTPUT          Bash glob pattern that defines the relevant output of
                    work commands.
                    Default: '*.pdf *.log'
HELP
)"

# Make sure the main folders exist
mkdir -p "${SRC_DIR}" "${TMP_DIR}" "${OUT_DIR}"

case "${command}" in
    "" | "help" )
        echo "${documentation}"
        ;;
    "version" )
        cat /version
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
                shift
                work_command="$@"

                if [[ -f "${SRC_DIR}/${BUILDSCRIPT}" ]]; then
                    echo "Work command overrides build script ${BUILDSCRIPT}."
                fi
            ;;
        esac

        # Install dependencies
        hashfile="${TMP_DIR}/${TEXLIVEFILE}.sha"
        mkdir -p $(dirname ${hashfile})
        if [[ -f "${SRC_DIR}/${TEXLIVEFILE}" ]]; then
            if ! sha256sum -c "${hashfile}" > /dev/null 2>&1; then
                echo "Installing dependencies ..."
                tlmgr update --self
                xargs tlmgr install < "${SRC_DIR}/${TEXLIVEFILE}"
                sha256sum "${SRC_DIR}/${TEXLIVEFILE}" > "${hashfile}"
            else
                echo "${TEXLIVEFILE} has not changed; nothing new to install."
            fi
        else
            echo "${TEXLIVEFILE} not found; continuing without installing additional packages."
        fi
        echo ""

        # Execute command on a copy of the sources
        set +e # continue even if globs don't match
        cp -rf "${SRC_DIR}"/* "${TMP_DIR}"/
        cd "${TMP_DIR}"
        rm -f ${OUTPUT}
        bash -c "${work_command}"; work_status=$?
        cp ${OUTPUT} "${OUT_DIR}"/

        exit ${work_status}
        ;;
    * )
        echo "Unknown command '${command}'"
        exit 1
        ;;
esac
