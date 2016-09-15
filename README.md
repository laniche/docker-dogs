# Docker for Dogs

This document describe how to install and use [Docker](http://docker.com) as part of our developments. It does'nt explain what's Docker, Container, and so. If you want more informations about that, please, ... **[RTFM!](https://docs.docker.com/)**

## Install "Docker for Mac"

It's now possibile to install Docker directly on your Mac, without need of Virtualbox.

> If you already have "Docker Toolbox" installed, read [this page](https://docs.docker.com/docker-for-mac/docker-toolbox/) and follow   the described steps before installer Docker for Mac.

1. Download the application "[Docker for Mac](https://www.docker.com/products/docker#/mac)"
1. Unpack the app and start the installation.

After the application start, you can edit preferences : 

* Increase to `4Cpus` and `4Gb` (or more) in "General" tab
* and uncheck "Automatic Update" to avoid problems with a broken release.
* Uncheck usage and crash report in the "Privacy" tab.

At this point, a Docker deamon is started on your machine and you can deploy container directly on it.

> You can test your installation with `docker run hello-world`
> Then, run `docker ps -a` to see the container list...
> and `docker rm hello-world` to remove this useless container.

## The basic command

> , that we will not use !

To manage your containers, you normaly use `docker` command ; But this commande (and all his parameters) is used to controlle one container at a time.
In our project, we want you multiple containers : for web service, database, mail catching, ...
Then we prefere to use `docker-compose`...

> It is significant that even to know how work this command then, one more time, **[RTFM!](https://docs.docker.com/engine/reference/commandline/#the-docker-commands)**

## Using Docker (compose), for every day

We use `docker-compose` to create environnement for our projects. That's a utility provided by Docker to prepare a bundle of containers and those interactions (Ports, Volumes).

> Look at [Docker Compose Manual](https://docs.docker.com/compose/overview/).

In each one, you can find :

- a `docker` folder with sub-folder for our container definitions
- and a `docker-compose.yml` that describe how Docker must use these containers.

In the `docker` folder of the project, there is samples `yml` files they provide template for your `docker-compose.yml`.
_It's important to keep the name `docker-compose.yml`._

### Start / Stop

* Go on the root of your project and `docker-compose build` to create to container images.
* then use `docker-compose up -d` to start your docker projets (in background with `-d` option)
* You can type `docker logs -f` to show the flow of logs during your work session
* and `docker-compose down` to stop the containers.

The first time you start a `docker-compose` for your project, it take a while because he need download the images and build the containers.

### Datas persistancy

> TODO !

### Command aliases

> TODO !

---

### Disclaimer

In our projects, we will use the most simple container as possible : 

1. A container with _Apache+PHP_
2. An other one with _Maria DB_
3. (optionnaly some others for elastic, mailcatcher, ...)

If you want add other containers or change the infrastructure, make it at your own risk. 
