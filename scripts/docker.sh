#!/bin/bash
#
#   Docker aliases and commands
#
# -----------------------------------------------------------------------------

export DOCKER_PREFIX="\033[4mDOCKER\033[0m -"

COLOR_RED="\033[0;31m"
COLOR_YELLOW="\033[1;33m"
COLOR_GREEN="\033[0;32m"
COLOR_BLUE="\033[1;34m"
COLOR_LIGHT_RED="\033[1;31m"
COLOR_LIGHT_GREEN="\033[1;32m"
COLOR_WHITE="\033[1;37m"
COLOR_LIGHT_GRAY="\033[0;37m"
COLOR_NONE="\033[0m"

if [ -e "$(which docker)" ]; then	

    function _dockerMachineName()
    {
        export DOCKER_MACHINE_NAME="${DOCKER_MACHINE_NAME:-$(docker info |awk -F':' '/Name/ {print $2}' | tr -d ' ')}"
        export DOCKER_MACHINE_IP='127.0.0.1'
    }

    # -------------------------------------------------------------------------

    function _dockerAlias()
    {
        alias doco="docker-compose"

        alias doup="doco build && doco up -d"
        alias dodown="doco stop"
        alias dorestart="dodown && doup"
        alias doreload="dodown && doup"
        alias dologs="doco logs"
    }
    
    # -------------------------------------------------------------------------

    function _dockerInit()
    {
        _dockerMachineName $1
        
        if ! docker info 2>&1 >/dev/null ; then
            echo -e "${DOCKER_PREFIX} Local deamon ${DOCKER_MACHINE_NAME} is ${COLOR_RED}not running${COLOR_NONE}\n"
            return 1
        fi
        
        echo -e "${DOCKER_PREFIX} Local deamon \"${DOCKER_MACHINE_NAME}\" is ${COLOR_GREEN}running${COLOR_NONE} on ${DOCKER_MACHINE_IP}.\n"
        _dockerAlias
    }

    # -------------------------------------------------------------------------

    # Update and restart DnsMask (if present)
    function _updateDnsMask()
    {
        if [ -f $(brew --prefix)/etc/dnsmasq.conf ]; then
            if ! grep "${DOCKER_MACHINE_IP}" $(brew --prefix)/etc/dnsmasq.conf >/dev/null ; then
                echo -e "${DOCKER_PREFIX} I need ${COLOR_BLUE}update DnsMask${COLOR_NONE} to match IP: ${DOCKER_MACHINE_IP}."

                sed -i -e "s|dok/[0-9.]*$|dok/${DOCKER_MACHINE_IP}|" $(brew --prefix)/etc/dnsmasq.conf
                sudo launchctl stop homebrew.mxcl.dnsmasq && sudo killall -HUP mDNSResponder && sudo launchctl start homebrew.mxcl.dnsmasq
            fi
        fi
    }

    # -------------------------------------------------------------------------

    # Run a shell in the specified container
    function doshell()
    {
        docker exec -t -i $1 /bin/bash
    }
    

    # -------------------------------------------------------------------------

    function dohelp()
    {
        echo -e "${DOCKER_PREFIX} Helper Commands.\n"
    
        echo -e "  ${COLOR_BLUE}doup${COLOR_NONE} : Build and Up the current Docker compose."
        echo -e "  ${COLOR_BLUE}dodown${COLOR_NONE} : Down the current Docker compose."
        echo -e "  ${COLOR_BLUE}doreload${COLOR_NONE} : Down and up the current Docker compose."
        echo -e "  ${COLOR_BLUE}doshell${COLOR_NONE} : Open shell on specified container (autocomplete)."
        echo -e "  ${COLOR_BLUE}dologs${COLOR_NONE} : Start the Logging system for the current Docker compose."

        echo -e "  ${COLOR_LIGHT_GRAY}doco${COLOR_NONE} : Simple alias for docker-compose."
    }

    # -------------------------------------------------------------------------
    # Autocompleter

    if $(type complete >/dev/null); then    
        function _completeshell()
        {
            local word="${COMP_WORDS[COMP_CWORD]}"
            COMPREPLY=( $(compgen -W "$(docker ps --filter status=running --format "{{.Names}}")" -- "$word") )
        }
        complete -F _completeshell doshell

    fi

    # -------------------------------------------------------------------------
    # Init

    _dockerInit
fi