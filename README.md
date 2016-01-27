## Installer et configurer Docker

Pour installer Docker sur votre **Mac** :

Installer la dernière version de **[DockerToolbox](https://www.docker.com/docker-toolbox)**. A la fin de l'installation il vous propose de choisir un outil pour démarrer avec Docker, cliquez simplement sur `Docker Quickstart Terminal`, choisissez votre shell et ensuite patientez.

La vm est créée mais on aimerait avoir une ip custom. Pour ça une petite modification est nécessaire.

1. Coupez la VM : `docker-machine stop default`
2. Executez cette commande dans votre terminal : `sed -i -e "s|$(egrep "HostOnlyCIDR" ~/.docker/machine/machines/default/config.json | cut -d '"' -f 4)|10.0.3.1/24|" ~/.docker/machine/machines/default/config.json`
3. Relancez la VM : `docker-machine start default`
4. Regénérez les certificats SSL : `docker-machine regenerate-certs default -f`

_Grâce à l'ip que l'on passe ci-dessus, votre vm bootera avec l'ip **10.0.3.100**_

### Optionnel 

Si vous ne voulez plus éditer votre fichier `/etc/hosts` à la main pour chaque nouveau site sur lequel vous bossez, vous pouvez installer `dnsmasq` en éxecutant ces commandes :

```
brew install dnsmasq
mkdir -pv $(brew --prefix)/etc/
echo 'address=/.dok/10.0.3.100' > $(brew --prefix)/etc/dnsmasq.conf
sudo cp -v $(brew --prefix dnsmasq)/homebrew.mxcl.dnsmasq.plist /Library/LaunchDaemons
sudo launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
sudo mkdir -v /etc/resolver
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/dok'
```

Toutes les adresses avec le domaine `.dok` pointent maintenant sur l'ip `10.0.3.100` et donc si votre vm tourne, vous devriez maintenant pouvoir pinger nimportequoi.dok. Si ça ne ping pas, redémarrez votre Mac.

## Utilisation de Docker

Pour pouvoir lancer des containers il faut d'abord s'assurer que votre vm tourne. Le script `startup.sh` s'occupe de lancer la VM + les containers de bases (nginx-proxy). 
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

_Si c'est la première fois que vous utilisez ce yml, il va prendre du temps pour provisionner les différents containers._

Vous pouvez maintenance taper `host.dok` dans votre browser pour accéder au site.

---

## Script `docker_commands.sh`

Il s'agit d'un script qui permet d'ajouter des commandes pour simplifier l'utilisation quotidienne de Docker.

_Il est également présent dans le répository `Devtools / Terminaldog`._

### Installation

Il suffit d'exécuter la commandes suivantes (utilisation de bash): 

    mkdir -p ~/.scripts && cp docker_commands.sh ~/.scripts
    echo "source ~/.scripts/docker_commands.sh" >> ~/.bashrc

Ou, pour les utilisateurs de ZSH, de modifier la 2eme ligne pour pointer votre fichier de configuration (si différent)._


