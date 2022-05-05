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
$ mkdir -p ~/.citadel-dev && curl -#L https://github.com/runcitadel/citadel-dev/tarball/docker-in-docker | tar -xzv --strip-components 1 --exclude={README.md,LICENSES,LICENSE,.gitignore} -C ~/.citadel-dev
```

Running the above command downloads the repository to ~/.citadel-dev. To update later on, just run that command again.

### Add to $PATH

Make the command available in your shell

```
$ export PATH="$PATH:$HOME/.citadel-dev/bin"
```

If you want to have it permanently, also add the line to the correct profile file (~/.bash_profile, ~/.zshrc, ~/.profile, or ~/.bashrc).

### Install Dependencies

Install the required dependencies if you haven't already

```
$ citadel-dev install
```

## Usage

Start Citadel and login in with the default credentials (user: _citadel_, password: _freedom_)

```
$ citadel-dev boot
```

List all possible commands

```
$ citadel-dev
```

## License

All code committed on and before git commit `874d4d8` is licensed via MIT and © Umbrel

All code committed after git commit `874d4d8` is licensed GPL v3
