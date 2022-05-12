# Citadel CLI

Automatically initialize and manage a Citadel.

This installation method uses nested Docker containers (Docker-in-Docker) for a lightweight and fast way to get up and running with Citadel.
Sysbox enables us to do this in a way that is **easy and secure**. The inner Docker is **totally isolated** from the Docker on the host.

## Installation

### Requirements

- [Docker](https://docs.docker.com/get-docker/)
- [Sysbox](https://github.com/nestybox/sysbox/blob/master/docs/user-guide/install-package.md)
- 4GB RAM and 600GB disk space (for mainnet)

### Install & Update Script

```shell
mkdir -p ~/.citadel && curl -#L https://github.com/runcitadel/citadel-dev/tarball/main | tar -xzv --strip-components 1 --exclude={README.md,LICENSES,LICENSE,.gitignore} -C ~/.citadel
```

Running the above command downloads the repository to ~/.citadel. To update later on, just run that command again.

### Add to $PATH

Make the command available in your shell

```shell
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

```shell
citadel boot
```

List all possible commands

```shell
citadel help
```

## Development

This CLI also serves as an easy way to bootstrap a development environment with hot module replacement for rapid iterations.
For linking @runcitadel packages use `yarn link -r ../<package>` & `yarn unlink ../<package>` as needed from the appropriate directory.

```shell
citadel dev <directory>
```

## Troubleshoot

Run `docker info` and make sure you have "overlay2" configured as your storage driver and that docker knows about Sysbox as a runtime.

- Unknown runtime specified sysbox-runc

https://github.com/nestybox/sysbox/blob/master/docs/user-guide/troubleshoot.md#docker-reports-unknown-runtime-error

- Inner containers fail to start / stop

Make sure you have "overlay2" configured as your storage driver, see https://docs.docker.com/storage/storagedriver/overlayfs-driver/

For Sysbox related issues see https://github.com/nestybox/sysbox/blob/master/docs/user-guide/troubleshoot.md

## License

All code committed on and before git commit `874d4d8` is licensed via MIT and © Umbrel

All code committed after git commit `874d4d8` is licensed GPL v3
