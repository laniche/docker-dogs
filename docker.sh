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

    #
    #   DEPRECATED with docker native app
    # 
    function _dockerMachineName()
    {
        export DOCKER_MACHINE_NAME="${DOCKER_MACHINE_NAME:-$(docker info |awk -F':' '/Name/ {print $2}' | tr -d ' ')}"
        export DOCKER_MACHINE_IP='127.0.0.1'
    }

    # -------------------------------------------------------------------------

    function _dockerAlias()
    {
        alias doup="docker-compose build && docker-compose up -d"
        alias dodown="docker-compose stop"
        alias dorestart="dodown && doup"
        alias doreload="dodown && doup"
        alias dologs="docker-compose logs"
    }
    
    # -------------------------------------------------------------------------

    function _dockerInit()
    {
        _dockerMachineName $1
        
        if ! docker info 2>&1 >/dev/null ; then
            echo -e "${DOCKER_PREFIX} Machine ${DOCKER_MACHINE_NAME} is ${COLOR_RED}not running${COLOR_NONE}\n"
            return 1
        fi
        echo -e "${DOCKER_PREFIX} Machine ${DOCKER_MACHINE_NAME} is ${COLOR_GREEN}running${COLOR_NONE} on ${DOCKER_MACHINE_IP}.\n"

        _dockerAlias
        _updateDnsMask
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

    function dostart()
    {
        _dockerInit $1

        # Check if the container nginx-proxy already exists run <> start
        if [ $(docker ps -a -f name=nginx-proxy -q) ] ; then
            docker start nginx-proxy
        else
            DOCKER_NGINX_EXTRAS="$(pwd)/docker_nginx_extras.conf"
            if [ ! -e $DOCKER_NGINX_EXTRAS ]; then 
                echo -e "# NginX Custom Config\nclient_max_body_size 10m;" > ${DOCKER_NGINX_EXTRAS}
            fi

            docker run --name=nginx-proxy -d -p 80:80 -v ${DOCKER_NGINX_EXTRAS}:/etc/nginx/conf.d/extras.conf -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy
        fi
    }

    # -------------------------------------------------------------------------

    function dostop()
    {
        _dockerMachineName $1
        
        if [ $(docker ps -a -f name=nginx-proxy -q) ] ; then
            docker stop nginx-proxy
        fi

        echo -e "\n${DOCKER_PREFIX} Machine ${DOCKER_MACHINE_NAME} is ${COLOR_GREEN}stopped${COLOR_NONE}, now\n"
    }

    # -------------------------------------------------------------------------

    function dodb()
    {
        if [ "$1" == "-t" ]; then
            DOCKER_MYSQL_PORT=$(docker ps --filter status=running --format "{{.Ports}}" --filter name="$2" | awk -F'[:-]' '/3306/{ print $2 ; exit }')
            ssh -i ~/.docker/machine/machines/${DOCKER_MACHINE_NAME}/id_rsa -L 3306:localhost:${DOCKER_MYSQL_PORT} docker@mysql.dok

        else
            DOCKER_MYSQL_PORT=$(docker ps --filter status=running --format "{{.Ports}}" --filter name="$2" | awk -F'[:-]' '/3306/{ print $2 ; exit }')
            echo "The Port is : $DOCKER_MYSQL_PORT"
            which pbcopy2 2>&1 >/dev/null && (echo $DOCKER_MYSQL_PORT | pbcopy)
        fi
    }

    # -------------------------------------------------------------------------

    function dohelp()
    {
        echo -e "${DOCKER_PREFIX} Helper Commands.\n"
        echo -e "  ${COLOR_BLUE}dostart${COLOR_NONE} : Detect and start a Docker VM."
        echo -e "  ${COLOR_BLUE}dostop${COLOR_NONE} : Stop the connected Docker VM."
        echo -e "  ${COLOR_BLUE}doconnect${COLOR_NONE} : Set Docker environnement for your shell."
        echo -e "  ${COLOR_BLUE}doup${COLOR_NONE} : Build and Up the current Docker compose."
        echo -e "  ${COLOR_BLUE}dodown${COLOR_NONE} : Down the current Docker compose."
        echo -e "  ${COLOR_BLUE}doshell${COLOR_NONE} : Open shell on specified container."
        echo -e "  ${COLOR_BLUE}dodb [-t]${COLOR_NONE} : Open tunnel to DB or at least get the forwarded port."
        echo -e "  ${COLOR_BLUE}dologs${COLOR_NONE} : Start the Logging system for the current Docker compose."
    }

    # -------------------------------------------------------------------------
    # Autocompleter

    if $(type complete >/dev/null); then    
        function _completedb()
        {
            local word="${COMP_WORDS[COMP_CWORD]}"
            COMPREPLY=( $(compgen -W "$(docker ps --filter status=running --format "{{.Names}} {{.Ports}}" | awk '/3306/{print $1}')" -- "$word") )
        }
        complete -F _completedb dodb

    fi

    # -------------------------------------------------------------------------
    # Init

    _dockerInit
fi