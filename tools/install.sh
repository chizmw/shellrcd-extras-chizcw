#!/bin/sh
# vim: filetype=sh:et:ts=4:sts=4:sw=4:si:ai
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/chiselwright/shellrcd/master/tools/install.sh)"
# or wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/chiselwright/shellrcd/master/tools/install.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   curl -fsSL -o ~/install-shellrcd.sh https://raw.githubusercontent.com/chiselwright/shellrcd/master/tools/install.sh
#   $EDITOR ~/install-shellrcd.sh
#   sh -c ~/install-shellrcd.sh

set -eu

# stolen from https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
command_exists() {
    command -v "$@" >/dev/null 2>&1
}

# stolen from https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
setup_color() {
    # Only use colors if connected to a terminal
    if [ -t 1 ]; then
        RED=$(printf '\033[31m')
        GREEN=$(printf '\033[32m')
        YELLOW=$(printf '\033[33m')
        RESET=$(printf '\033[m')
    else
        RED=""
        GREEN=""
        YELLOW=""
        RESET=""
    fi
}

already_installed() {
    # https://unix.stackexchange.com/questions/330660/prevent-grep-from-exiting-in-case-of-nomatch/403707#comment581721_330662
    count=$(grep -c '^## added by shellrcd ##' "${1:?Missing Argument}" || :)
    [ "$count" -gt 0 ]
}

write_new_file() {
    rcfile=${1:?Missing rcfile}
    shell=${2:?Missing shell}

    echo "#!${shell}" > "${rcfile}"
    append_block "${rcfile}"
}

append_block() {
    cat >> "${1:?Missing rcfile argument}" <<EOF

## added by shellrcd ##
if [ -f ~/.shellrc.d/source-relevant-files -a -x ~/.shellrc.d/source-relevant-files ]; then
    source ~/.shellrc.d/source-relevant-files
fi
## end of shellrcd block ##

EOF
}

append_or_create() {
    rcfile=${1:?Missing rcfile}
    shell=${2:?Missing shell}

    if [ -f "${rcfile}" ] || [ -h "${rcfile}" ]; then
        if already_installed "${rcfile}"; then
            echo "[${shell}] ${RED}shellrcd block already added to ${rcfile}${RESET}. Nothing to do."
        else
            echo "[${shell}] Adding shellrcd block to ${YELLOW}${rcfile}${RESET}..."
            append_block "${rcfile}"
        fi
    else
        echo "[${shell}] Creating ${YELLOW}${rcfile}${RESET} and adding shellrcd block..."
        write_new_file "$rcfile" "$(which "${shell}")"
    fi
}

setup_zshrc() {
    rcfile=~/.zshrc
    shell=zsh

    echo "[${shell}] ${YELLOW}Looking for an existing zsh config...${RESET}"

    append_or_create "${rcfile}" "${shell}"
}

setup_bashrc() {
    unset rcfile
    shell=bash

    echo "[${shell}] ${YELLOW}Looking for an existing bash config...${RESET}"

    # we should use .bash_profile if we're being "proper" on a mac
    # but for the rest of the world, .bashrc seems to be acceptable
    # https://serverfault.com/a/376264
    case "$(uname)" in
        Darwin*)
            echo "[${shell}] ${RED}MacOS${RESET} detected. Using ${YELLOW}.bash_profile${RESET}."
            rcfile=~/.bash_profile
            ;;
        *)
            echo "[${shell}] ${RED}Non-MacOS${RESET} detected. Using ${YELLOW}.bashrc${RESET}."
            rcfile=~/.bashrc
            ;;
    esac

    append_or_create "${rcfile}" "${shell}"
}

main() {
    setup_color

    if ! command_exists zsh; then
        echo "${YELLOW}zsh is not installed.${RESET} Skipping ${GREEN}zsh${RESET} setup."
    else
        setup_zshrc
    fi

    if ! command_exists bash; then
        echo "${YELLOW}bash is not installed.${RESET} Skipping ${GREEN}bash${RESET} setup."
    else
        setup_bashrc
    fi
}

main "$@"