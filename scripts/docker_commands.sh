#!/bin/bash
#
#   Docker aliases and commands
#
#   Add this script to your ".(ba|z)shrc" to add userfriendly aliases
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

# -----------------------------------------------------------------------------
# Validation
if [ -z "$(command -v docker)" ]; then
    echo -e "${DOCKER_PREFIX} command \"docker\" ${COLOR_RED}not installed${COLOR_NONE}. Abording.\n"
fi

# -----------------------------------------------------------------------------
# Auto installation

DOCKER_PATH="$HOME/.docker"
DOCKER_SCRIPT="docker_commands.sh"
DOCKER_URL="https://raw.githubusercontent.com/Dogstudio/docker-dogs/master/scripts/${DOCKER_SCRIPT}"

[ "$(basename -- $0)" != "$(basename $DOCKER_SCRIPT)" ] && [ -z "${BASH_SOURCE[0]}" ] && (
    # If ROOT, install globally
    [ "$(id -u)" == "0" ] && DOCKER_PATH="/usr/local/bin"
    
    # Install the file
    [ -d "$DOCKER_PATH" ] || mkdir -p $DOCKER_PATH
    curl -sS -o ${DOCKER_PATH}/${DOCKER_SCRIPT} ${DOCKER_URL}
    
    # Add the script in your .(ba|z)shr
    if [ -e "${DOCKER_PATH}/${DOCKER_SCRIPT}" ]; then
        [ -e "$HOME/.bashrc" ] && \
        grep -Fq "${DOCKER_PATH}/${DOCKER_SCRIPT}" "$HOME/.bashrc" || \
        echo "source ${DOCKER_PATH}/${DOCKER_SCRIPT}" >> $HOME/.bashrc

        [ -e "$HOME/.zshrc" ] && \
        grep -Fq "${DOCKER_PATH}/${DOCKER_SCRIPT}" "$HOME/.zshrc" || \
        echo "source ${DOCKER_PATH}/${DOCKER_SCRIPT}" >> $HOME/.zshrc
    fi

    echo -e "${DOCKER_PREFIX} Commands installed ${COLOR_GREEN}successfully${COLOR_NONE}\n"
)

# -----------------------------------------------------------------------------


function _dockerAlias()
{
    alias doco="docker-compose"

    alias doup="docker-compose build && docker-compose up -d"
    alias dodown="docker-compose stop"
    alias dorestart="dodown && doup"
    alias doreload="dodown && doup"
    alias dologs="docker-compose logs"

    alias do="docker-compose rm && docker-compose build --no-cache --force-rm && docker-compose up -d"
}

# -------------------------------------------------------------------------

function _dockerInit()
{        
    if ! docker info 2>&1 >/dev/null ; then
        echo -e "${DOCKER_PREFIX} Local deamon is ${COLOR_RED}not running${COLOR_NONE}\n"; return 1
    fi
    
    DOCKER_MACHINE_NAME=$(docker info |awk -F':' '/Name/ {print $2}' | tr -d ' ')
    echo -e "${DOCKER_PREFIX} Local deamon \"${DOCKER_MACHINE_NAME}\" is ${COLOR_GREEN}running${COLOR_NONE}.\n"
    
    _dockerAlias
    _updateDnsMask
}

# -------------------------------------------------------------------------

# Update and restart dnsmasq (if present)
function _updateDnsMask()
{
    DNSMASQ_CONF="$(brew --prefix)/etc/dnsmasq.conf"
    DOCKER_MACHINE_IP='127.0.0.1'

    if [ -f $DNSMASQ_CONF ]; then
        if ! grep "${DOCKER_MACHINE_IP}" $DNSMASQ_CONF >/dev/null ; then
            echo -e "${DOCKER_PREFIX} I need ${COLOR_BLUE}update dnsmasq${COLOR_NONE} to match IP: ${DOCKER_MACHINE_IP}."
            sed -i -e "s|dok/[0-9.]*$|dok/${DOCKER_MACHINE_IP}|" $DNSMASQ_CONF
            
            sudo launchctl stop homebrew.mxcl.dnsmasq && 
            sudo killall -HUP mDNSResponder && 
            sudo launchctl start homebrew.mxcl.dnsmasq
        fi
    fi
}

# -------------------------------------------------------------------------

# Run a shell on the specified container
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

    echo -e "  ${COLOR_WHITE}doco${COLOR_NONE} : Simple alias for docker-compose."
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
