# Docker Toolbox

> Previously, it was necessary to install a VBox because Docker was'nt supported nativelly on OSX. 
> We keep this procedure for historical reasons.

Install the latest version of **[DockerToolbox](https://www.docker.com/docker-toolbox)**. 
At the end of installation, the system ask you to choise which tool you wan use to start Docker, click on `Docker Quickstart Terminal`, select you shell and wait.

The virtual machine is now ready but we want have a custom IP. Then we need a little modification :

1. Stop the VM : `docker-machine stop default`
2. Execute this command : `sed -i -e "s|$(egrep "HostOnlyCIDR" ~/.docker/machine/machines/default/config.json | cut -d '"' -f 4)|10.0.3.1/24|" ~/.docker/machine/machines/default/config.json`
3. Restart the VM : `docker-machine start default`
4. Recreate the SSL certificate : `docker-machine regenerate-certs default -f`