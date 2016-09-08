# Docker for Dogs

## Install and configure Docker

> To install [Docker](http://docker.com) on your Mac...

It's now possibile ton install Docker directly on your Mac, without need of Virtualbox.

1. Download the application "Docker for Mac" from the site [Docker.com](https://www.docker.com/products/docker#/mac)
1. Unpack the app and start the installation

`TODO : complete the installation doc.`

### Docker Toolbox

> Previously, it was necessary to install a VBox because Docker was'nt supported nativelly on OSX. 
> We keep this procedire here for historical reasons.

Installer la dernière version de **[DockerToolbox](https://www.docker.com/docker-toolbox)**. A la fin de l'installation il vous propose de choisir un outil pour démarrer avec Docker, cliquez simplement sur `Docker Quickstart Terminal`, choisissez votre shell et ensuite patientez.

La vm est créée mais on aimerait avoir une ip custom. Pour ça une petite modification est nécessaire.

1. Coupez la VM : `docker-machine stop default`
2. Executez cette commande dans votre terminal : `sed -i -e "s|$(egrep "HostOnlyCIDR" ~/.docker/machine/machines/default/config.json | cut -d '"' -f 4)|10.0.3.1/24|" ~/.docker/machine/machines/default/config.json`
3. Relancez la VM : `docker-machine start default`
4. Regénérez les certificats SSL : `docker-machine regenerate-certs default -f`

_Grâce à l'ip que l'on passe ci-dessus, votre vm bootera avec l'ip **10.0.3.100**_

## Using Docker

> TODO: refactor this part of documentation...

Pour pouvoir lancer des containers il faut d'abord s'assurer que votre vm tourne.
Le script `startup.sh` s'occupe de lancer la VM + les containers de bases (nginx-proxy). 
Vous pouvez déplacer ce script dans un `/usr/local/bin` pour en faire une commande et pour pouvoir l'appeller depuis n'importe où.
Pour cela, exécutez les commandes suivantes :

```
sudo cp startup.sh /usr/local/bin/docker-start
rehash
```

Vous pouvez maintenant taper `docker-start` pour lancer tout ce qui est nécessaire à l'utilisation de Docker. Une fois que le script a fini de tourner, vous êtes prêt à utiliser Docker.

Il y a un dossier `docker` ou plus précisemment `docker/samples` qui contient tout ce qu'il faut. Nous utilisons `docker-compose` qui permet en gros de lancer un pool de container grâce à un fichier de config yml. 
Le dossier `samples` contient des yml qui sont utilisables out of the box. Il vous suffit d'en choisir un et de le copier à la racine de votre projet :

```
cp docker/samples/apache-mysql.yml docker-compose.yml
```

_C'est important de garder le nom `docker-compose.yml`._

Editer le yml et adaptez le à votre convenance. Modifier le `VIRTUAL_HOST` et le nom de la db `MYSQL_DATABASE`. Vous pouvez ensuite lancer les container :

```
docker-compose up -d
```

_Si c'est la première fois que vous utilisez ce yml, il va prendre du temps pour "provisionner" les différents containers._

Vous pouvez maintenance taper `host.dok` dans votre browser pour accéder au site.
