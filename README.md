# Docker for Dogs

This document describe how to install and use [Docker](http://docker.com) as part of our developments.  
It does'nt explain what's Docker, Container, and so. If you want more informations about that, please, ...
**[RTFM!](https://docs.docker.com/)**

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

## The basic commands

To manage your containers, you normally use the `docker` command ; But this command (and all his parameters) is used to control one container at a time.
In our projects, we want use multiple containers : for web service, database, mail catching, ...
So, we will use `docker-compose`...

> It is important to even know how work this command so, one more time, **[RTFM!](https://docs.docker.com/engine/reference/commandline/#the-docker-commands)**

## Add Docker to my project

If your project respect the _Dogstudio project strucuture_, using Docker is extremaly simple :

1. Create a `docker-compose.yml` (see below) in your `root` project.
1. Start docker with `docker-compose up -d` (or `doup` if you use short commands, see below)

When you finish your work on project : 

1. Simply stop the containers with `docker-compose down` OR `docker stop $(docker ps -q)` (if you're outside the project folder).

> These commands are really simplified. For more informations, you know what...

## Using Docker (compose), for every day

We use `docker-compose` to create environnement for our projects. 
That's a utility provided by Docker to prepare a bundle of containers and those interactions (Ports, Volumes).

### `docker-compose.yml`example: 

You can copy it in your project root folder.

```
version: "2"
services:
  database:
    image: dogstudio/mariadb
    ports:
      - "3306:3306"

  php:
    image: dogstudio/php:56-fpm
    volumes:
      - "./dev:/var/www/dev"

  web:
    image: dogstudio/nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "./dev:/var/www/dev"
      - "./cut:/var/www/cut"
      - "./database:/var/www/database"
```

Here we define 3 containers : 

1. One for `database` using _MariaDB_ image
1. One for `php` using the _FPM_ in version 7
1. One for `web` proxing request to PHP using _NginX_

In the last one, we set 3 folders as volumes for : `dev`, `cut` and `database`.

> Look at [Docker Compose Manual](https://docs.docker.com/compose/overview/).

### Start / Stop

* Go on the root of your project and `docker-compose build` to create to container images.
* then use `docker-compose up -d` to start your docker projets (in background with `-d` option)
* You can type `docker logs -f` to show the flow of logs during your work session
* and `docker-compose down` to stop the containers.

The first time you start a `docker-compose` for your project, it take a while because he need download the images and build the containers.

### Command aliases

We have created a shell script that provide user friendly commands for you daily use of Docker.

You can install it with :

    curl -s https://raw.githubusercontent.com/dogstudio/docker-dogs/master/scripts/docker_commands.sh | bash

This script provides shortcut functions like : 

* `doup` : Build and Up the current Docker compose.
* `dodown` : Down the current Docker compose.
* `doreload` : Down and up the current Docker compose.
* `doshell` : Open shell on specified container (autocomplete).
* `dologs` : Start the Logging system for the current Docker compose.
* `doco` : Simple alias for docker-compose.

---

### Disclaimer

In our projects, we will use the most simple container as possible : 

1. A container with _Apache+PHP_ or _NginX+FPM_
2. An other one with _Maria DB_
3. (optionnaly some others for elastic, mailcatcher, ...)

If you want add other containers or change the infrastructure, make it at your own risk. 
