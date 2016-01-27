#!/bin/bash
export DOCKER_PREFIX="\033[4mDOCKER\033[0m -"
export DR="\033[0;31m"
export DG="\033[0;32m"
export DB="\033[1;34m"
export DN="\033[0m"

if [ -e "$(which docker-machine)" ]; then	

    function _dockerMachineName()
    {
        DOCKER_MACHINE_NAME="${1:-$DOCKER_MACHINE_NAME}"
        export DOCKER_MACHINE_NAME="${DOCKER_MACHINE_NAME:-$(docker-machine ls -q | head -n 1)}"
    }

    # -------------------------------------------------------------------------

    function _dockerAlias()
    {
        alias doup="docker-compose build && docker-compose up -d"
        alias dodown="docker-compose stop"
        alias dorestart="dodown && doup"
        alias dologs="docker-compose logs"
    }
    
    # -------------------------------------------------------------------------

    function _dockerInit()
    {
        _dockerMachineName $1

        if [ "Running" != $(docker-machine status ${DOCKER_MACHINE_NAME}) ]; then
            echo -e "${DOCKER_PREFIX} Machine ${DOCKER_MACHINE_NAME} is ${DR}not running${DN}\n"
            return 1
        fi
  
        eval $(docker-machine env $DOCKER_MACHINE_NAME) && 
        echo -e "${DOCKER_PREFIX} Machine ${DOCKER_MACHINE_NAME} is ${DG}running${DN} with IP : $(docker-machine ip ${DOCKER_MACHINE_NAME})\n"

        _dockerAlias
    }

    # -------------------------------------------------------------------------

    function _updateDnsMask()
    {
        # Update and restart DnsMask (if present)
        if [ -f $(brew --prefix)/etc/dnsmasq.conf ]; then
            if ! grep "$(docker-machine ip ${DOCKER_MACHINE_NAME})" $(brew --prefix)/etc/dnsmasq.conf >/dev/null ; then
                echo -e "${DOCKER_PREFIX} I need ${DB}update DnsMask${DN} to match IP: $(docker-machine ip ${DOCKER_MACHINE_NAME})."

                sed -i -e "s|/[0-9.]*$|/$(docker-machine ip ${DOCKER_MACHINE_NAME})|" $(brew --prefix)/etc/dnsmasq.conf
                sudo launchctl stop homebrew.mxcl.dnsmasq && sudo killall -HUP mDNSResponder && sudo launchctl start homebrew.mxcl.dnsmasq
            fi
        fi
    }

    # -------------------------------------------------------------------------

    function dostart()
    {
        _dockerMachineName $1

        if [ "Running" = $(docker-machine status ${DOCKER_MACHINE_NAME}) ]; then
            echo -e "${DOCKER_PREFIX} Machine ${DOCKER_MACHINE_NAME} is ${DG}already running${DN}  with IP : $(docker-machine ip ${DOCKER_MACHINE_NAME})\n"
            return 1
        fi
      
        docker-machine start ${DOCKER_MACHINE_NAME}

        until docker-machine env ${DOCKER_MACHINE_NAME} >/dev/null 2>&1; do
            if docker-machine env default 2>&1 | grep "docker-machine regenerate-certs" >/dev/null; then
                docker-machine regenerate-certs -f ${DOCKER_MACHINE_NAME}
            fi
            echo "." ; sleep 1
        done
        
        eval "$(docker-machine env ${DOCKER_MACHINE_NAME})"
        echo -e "${DOCKER_PREFIX} Machine ${DOCKER_MACHINE_NAME} is ${DG}started${DN} with IP : $(docker-machine ip ${DOCKER_MACHINE_NAME})\n"

        # Check if the container nginx-proxy already exists run <> start
        if [ $(docker ps -a -f name=nginx-proxy -q) ] ; then
            docker start nginx-proxy
        else
            docker run --name=nginx-proxy -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy
        fi
        
        _updateDnsMask
        _dockerAlias
    }

    # -------------------------------------------------------------------------

    function dostop()
    {
        _dockerMachineName $1

        if [ "Running" != $(docker-machine status ${DOCKER_MACHINE_NAME}) ]; then
            echo -e "${DOCKER_PREFIX} Machine ${DOCKER_MACHINE_NAME} is ${DG}already stopped${DN}\n"
            return 1
        fi

        docker-machine stop ${DOCKER_MACHINE_NAME}

        while docker-machine env ${DOCKER_MACHINE_NAME} >/dev/null 2>&1; do
            echo -n "." ; sleep 1
        done

        echo -e "\n${DOCKER_PREFIX} Machine ${DOCKER_MACHINE_NAME} is ${DG}stopped${DN}, now\n"
    }

    # -------------------------------------------------------------------------

    function doconnect()
    {
        _dockerMachineName $1

        if [ "Running" = $(docker-machine status ${DOCKER_MACHINE_NAME}) ]; then
            if $(docker-machine env ${DOCKER_MACHINE_NAME} >/dev/null 2>&1) ; then
                eval "$(docker-machine env ${DOCKER_MACHINE_NAME})"
                echo -e "${DOCKER_PREFIX} Machine ${DOCKER_MACHINE_NAME} is ${DG}connected${DN} with IP : $(docker-machine ip ${DOCKER_MACHINE_NAME})\n"

                _updateDnsMask
                _dockerAlias
            else
                echo -e "${DOCKER_PREFIX} Machine ${DOCKER_MACHINE_NAME} is ${DR}disconnected${DN}\n"
            fi
        else
            echo -e "${DOCKER_PREFIX} Machine ${DOCKER_MACHINE_NAME} is ${DR}stopped${DN}\n"
        fi
    }

    # -------------------------------------------------------------------------

    function doshell()
    {
        _dockerMachineName $1

        docker exec -ti ${DOCKER_MACHINE_NAME} /bin/bash
    }

    # -------------------------------------------------------------------------

    function dodb()
    {
        DOCKER_MYSQL_PORT=$(docker-compose ps | grep "3306" | head -n 1 | tr -s " " | cut -d " " -f 5 | cut -d ":" -f2 | cut -d "-" -f 1)
        ssh -i ~/.docker/machine/machines/${DOCKER_MACHINE_NAME}/id_rsa -L 3306:localhost:${DOCKER_MYSQL_PORT} docker@mysql.dok
    }

    # -------------------------------------------------------------------------

    function dohelp()
    {
        echo -e "${DOCKER_PREFIX} Helper Commands.\n"
        echo -e "  ${DB}dostart${DN} : Detect and start a Docker VM."
        echo -e "  ${DB}dostop${DN} : Stop the connected Docker VM."
        echo -e "  ${DB}doconnect${DN} : Set Docker environnement for your shell."
        echo -e "  ${DB}doup${DN} : Build and Up the current Docker compose."
        echo -e "  ${DB}dodown${DN} : Down the current Docker compose."
        echo -e "  ${DB}dologs${DN} : Start the Logging system for the current Docker compose."
    }

    # -------------------------------------------------------------------------
    # Autocompleter

    if $(type complete >/dev/null); then
        function _completecontainer()
        {
            local word="${COMP_WORDS[COMP_CWORD]}"
            COMPREPLY=( $(compgen -W "$(docker-compose ps | egrep "^[a-z].*" | cut -d" " -f1)" -- "$word") )
        }
        complete -F _completecontainer doshell

        function _completemachine()
        {
            local word="${COMP_WORDS[COMP_CWORD]}"
            COMPREPLY=( $(compgen -W "$(docker-machine ls -q)" -- "$word") )   
        }
        complete -F _completemachine dostart
        complete -F _completemachine dostop
        complete -F _completemachine doconnect
    fi

    # -------------------------------------------------------------------------
    # Init

    _dockerInit
fi