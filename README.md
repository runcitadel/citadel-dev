# citadel-dev

Automatically initialize and manage a Citadel development environment.

## Install

### Clone with Git

```
git clone https://github.com/runcitadel/citadel-dev.git ~/.citadel-dev
```

### Update Shell Profile

```shell
export PATH="$PATH:$HOME/.citadel-dev/bin"
```

### Install Vagrant

Run `citadel-setup` if you're on debian/ubuntu based Linux, and you've already completed the above steps. It runs the following:

```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get -y install vagrant
vagrant plugin install vagrant-reload
```

## Usage

```
$ citadel-dev
citadel-dev 1.2.1

Automatically initialize and manage an Citadel development environment.

Usage: citadel-dev <command> [options]

Commands:
    help                    Show this help message
    init                    Initialize an Citadel development environment in the working directory
    boot                    Boot the development VM
    shutdown                Shutdown the development VM
    destroy                 Destroy the development VM
    containers              List container services
    rebuild <container>     Rebuild a container service
    reload                  Reloads the Citadel service
    app <command> [options] Manages apps installations
    logs                    Stream Citadel logs
    run <command>           Run a command inside the development VM
    ssh                     Get an SSH session inside the development VM
```

## Licenses

All code committed on and before git commit `874d4d801f1bb04ded5155e303be31fe20a17e63` is licensed via MIT and © Umbrel

All code committed after git commit `874d4d801f1bb04ded5155e303be31fe20a17e63` is licensed GPL v3
