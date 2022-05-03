# Citadel (Docker-in-Docker)

Automatically initialize and manage a Citadel development environment.

This installation method uses nested Docker containers for a lightweight and fast way to get up and running with Citadel.
Sysbox enables us to do this in a way that is **easy and secure**. The inner Docker is **totally isolated** from the Docker on the host.

## Installation

### Requirements

- 4GB RAM and 600GB disk space (for mainnet)
- [Docker](https://docs.docker.com/get-docker/)
- [Sysbox](https://github.com/nestybox/sysbox/blob/master/docs/user-guide/install-package.md)

### Clone this repository

```
$ git clone -b docker-in-docker --depth=1 https://github.com/runcitadel/citadel-dev.git ~/.citadel-dev
```

### Update shell profile

```
$ export PATH="$PATH:$HOME/.citadel-dev/bin"
```

### Install required dependencies

```
$ citadel-dev install
```

### Start a Citadel container

```
$ citadel-dev boot
```

Login in with the default Citadel credentials (user: _citadel_, password: _freedom_)

## Usage

To see all possible commands:

```
$ citadel-dev help
```

## License

All code committed on and before git commit 874d4d801f1bb04ded5155e303be31fe20a17e63 is licensed via MIT and © Umbrel

All code committed after git commit 874d4d801f1bb04ded5155e303be31fe20a17e63 is licensed GPL v3
