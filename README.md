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
git clone -b docker-in-docker --depth=1 https://github.com/runcitadel/citadel-dev.git ~/.citadel-dev
```

### Update Shell Profile

```
export PATH="$PATH:$HOME/.citadel-dev/bin"
```

### Build the image

```
docker build -t citadel .
```

### Run the container

```
citadel-dev boot
```

Login in with the default Citadel credentials (user: _citadel_, password: _freedom_)

## Usage

```
$ citadel-dev
citadel-dev 1.3.0

Automatically initialize and manage isolated Citadel instances.

Usage: citadel-dev <command> [options]

Commands:
    help                    Show this help message
    init [options]          Initialize a Citadel environment in the working directory
    boot [options]          Start the container
    info                    Show the container IP
    start                   Start the container
    stop                    Stop the container
    reload                  Reloads the Citadel service
    destroy                 Destroy the container
    ssh <command>           Get an SSH session inside the container
    run <command>           Run a command inside the container
    containers              List container services
    rebuild <container>     Rebuild a container service
    app <command> [options] Manages apps installations
    logs                    Stream Citadel logs
    bitcoin-cli <command>   Run bitcoin-cli with arguments
    lncli <command>         Run lncli with arguments
    auto-mine <seconds>     Generate a block continuously
```

### Funding the Lightning wallet (development only)

1. Create a wallet with Bitcoin core:

```shell
$ citadel-dev bitcoin-cli createwallet "mywallet"
```

2. Generate some blocks to get funds:

```shell
$ citadel-dev bitcoin-cli -generate 101
```

3. Generate a new address with LND:

```shell
$ citadel-dev lncli -n regtest newaddress p2wkh
```

4. Send some funds to the new address:

```shell
$ citadel-dev bitcoin-cli -named sendtoaddress address="<my-address>" amount=0.5 fee_rate=1 replaceable=true
```

5. Mine some blocks to confirm the transaction:

```shell
$ citadel-dev bitcoin-cli -generate 6
```

6. You should now be able to open channels with other nodes in your network

## License

All code committed on and before git commit 874d4d801f1bb04ded5155e303be31fe20a17e63 is licensed via MIT and © Umbrel

All code committed after git commit 874d4d801f1bb04ded5155e303be31fe20a17e63 is licensed GPL v3
