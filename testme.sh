#!/bin/bash

DOCKER_PATH="$HOME/.docker"
DOCKER_SCRIPT="testme.sh"
DOCKER_URL="http://passtech.be/files/${DOCKER_SCRIPT}"

if [ "$(basename $0)" != "$(basename $DOCKER_SCRIPT)" ]; then
    # If ROOT, install globally
    [ "$(id -u)" == "0" ] && DOCKER_PATH="/usr/local/bin"
    
    [ -d "$DOCKER_PATH" ] || mkdir -p $DOCKER_PATH

    # [ -e "$DOCKER_PATH/$DOCKER_SCRIPT" ] && echo "Script already exist. Updating !"
    curl -sS -o ${DOCKER_PATH}/${DOCKER_SCRIPT} ${DOCKER_URL}

    exit 0;
fi

echo "Execute me !"