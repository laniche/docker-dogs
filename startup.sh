#!/bin/bash
DOCKER_MACHINE_NAME="default"

# Check if the VM is already running and restart it if it's the case
if [ "Running" = $(docker-machine status ${DOCKER_MACHINE_NAME}) ]; then
    docker-machine restart ${DOCKER_MACHINE_NAME}
else
    docker-machine start ${DOCKER_MACHINE_NAME}
fi

until docker-machine env ${DOCKER_MACHINE_NAME} >/dev/null 2>&1; do
    if docker-machine env default 2>&1 | grep "docker-machine regenerate-certs" >/dev/null; then
        docker-machine regenerate-certs -f ${DOCKER_MACHINE_NAME}
    fi
    echo "." ; sleep 1
done

eval "$(docker-machine env ${DOCKER_MACHINE_NAME})"

# Check if the container nginx-proxy already exists run <> start
if [ $(docker ps -a -f name=nginx-proxy -q) ] ; then
    docker start nginx-proxy
else
    docker run --name=nginx-proxy -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy
fi