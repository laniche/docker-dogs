# DNSMASQ

> DNSMASQ is a "micro DNS server" that you can easly install on your mac

If you don't want edit your `/etc/hosts`file manually when you work 
on a new project, you can install `dnsmasq` with these commands : 

## Requirement

You need ["Homebrew"](http://brew.sh/) to installe the packages for DNSMASQ.ets DNSMASQ.

    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

## Installation

1. Package installation :

        brew install dnsmasq

1. Create the configuration file :

        mkdir -pv $(brew --prefix)/etc/ && touch $(brew --prefix)/etc/dnsmasq.conf

        # For (old) Vagrant 
        echo 'address=/.dev/10.0.1.9' >> $(brew --prefix)/etc/dnsmasq.conf
        
        # For Docker Toolbox
        echo 'address=/.dok/10.0.0.30' >> $(brew --prefix)/etc/dnsmasq.conf
        
        # For Docker for mac
        echo 'address=/.dok/127.0.0.1' >> $(brew --prefix)/etc/dnsmasq.conf

1. Preparing and starting the service
    
        sudo cp -v $(brew --prefix dnsmasq)/homebrew.mxcl.dnsmasq.plist /Library/LaunchDaemons
        sudo launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist

1. Register the DNS server on your mac

        sudo mkdir -v /etc/resolver
        sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/dok'

That's it. Now if you try to access a domain the finish by:

* `.dev` : you will be redirected to `10.0.1.9` which corresponds to our **Vagrant**,
* `.dok` : you will be redirected to `127.0.0.1` (votre mac) with **Docker**.



You should now be able to pinge `nimportequoi.dok` or `unautresite.dev`. 
If this `ping` does not work, restart your Mac.

## Command resume

```
brew install dnsmasq
mkdir -pv $(brew --prefix)/etc/
echo 'address=/.dok/10.0.3.100' > $(brew --prefix)/etc/dnsmasq.conf
sudo cp -v $(brew --prefix dnsmasq)/homebrew.mxcl.dnsmasq.plist /Library/LaunchDaemons
sudo launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
sudo mkdir -v /etc/resolver
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/dok'
```
