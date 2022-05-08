# Citadel (Docker-in-Docker)

Automatically initialize and manage a Citadel.

This installation method uses nested Docker containers for a lightweight and fast way to get up and running with Citadel.
Sysbox enables us to do this in a way that is **easy and secure**. The inner Docker is **totally isolated** from the Docker on the host.

## Installation

### Requirements

- [Docker](https://docs.docker.com/get-docker/)
- [Sysbox](https://github.com/nestybox/sysbox/blob/master/docs/user-guide/install-package.md)
- 4GB RAM and 600GB disk space (for mainnet)

### Install & Update Script

```
mkdir -p ~/.citadel && curl -#L https://github.com/runcitadel/citadel-dev/tarball/docker-in-docker | tar -xzv --strip-components 1 --exclude={README.md,LICENSES,LICENSE,.gitignore} -C ~/.citadel
```

Running the above command downloads the repository to ~/.citadel. To update later on, just run that command again.

### Add to $PATH

Make the command available in your shell

```
export PATH="$PATH:$HOME/.citadel/bin"
```

If you want to have it permanently, also add the line to the correct profile file (~/.bash_profile, ~/.zshrc, ~/.profile, or ~/.bashrc).

### Install Dependencies

Install the required dependencies if you haven't already

```
citadel install
```

## Usage

Start Citadel and login in with the default credentials (user: _citadel_, password: _freedom_)

```
citadel boot
```

List all possible commands

```
citadel help
```

## Development

```
citadel dev <my-dev-machine>
```

## Troubleshoot

Run `docker info` and make sure you have "overlay2" configured as your storage driver and that docker knows about Sysbox as a runtime.

- Unknown runtime specified sysbox-runc

https://github.com/nestybox/sysbox/blob/master/docs/user-guide/troubleshoot.md#docker-reports-unknown-runtime-error

- Inner containers fail to start / stop

Make sure you have "overlay2" configured as your storage driver, see https://docs.docker.com/storage/storagedriver/overlayfs-driver/

## License

All code committed on and before git commit `874d4d8` is licensed via MIT and © Umbrel

All code committed after git commit `874d4d8` is licensed GPL v3
