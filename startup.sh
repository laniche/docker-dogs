#!/bin/bash
DOCKER_MACHINE_NAME="default"

# Check if the VM is already running
if [ "Running" = $(docker-machine status ${DOCKER_MACHINE_NAME}) ]; then
  echo -e "Machine ${DOCKER_MACHINE_NAME} is already running."
  exit 0
fi

# Start the VM and load ENV variables in current shell
docker-machine start ${DOCKER_MACHINE_NAME}
until $(docker-machine env ${DOCKER_MACHINE_NAME} >/dev/null 2>&1); do
  echo "." ; sleep 1
done
eval "$(docker-machine env ${DOCKER_MACHINE_NAME})"

# Check if the container nginx-proxy already exists run <> start
ret=$(docker ps -a | grep nginx-proxy)
if [ -n "$ret" ]; then
  docker start nginx-proxy
else
  docker run --name=nginx-proxy -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy
fi
