# Citadel (Docker-in-Docker)

This installation method uses nested Docker containers for a lightweight and fast way to get up and running with Citadel.
There are several ways to do this, but for security purposes we recommend installing the Sysbox version.

## Requirements

Make sure you have the following tools installed on your system 

- [Docker](https://docs.docker.com/get-docker/)
- [Sysbox](https://github.com/nestybox/sysbox/blob/master/docs/user-guide/install-package.md)

## Installation

### Clone this repository

```
git clone -b docker-in-docker https://github.com/runcitadel/citadel-dev
```

### Build the image

```
docker build -t citadel .
```

### Run the container

Run the container in priviledged mode and give it a hostname

```
docker run --privileged -d --name citadel --hostname citadel citadel
```

```
docker run --runtime sysbox-runc -it --name citadel --hostname citadel citadel
```

Login in with the default Citadel credentials (user: *citadel*, password: *freedom*)

### Check Citadel startup logs

Inside the container you can check Citadel service logs with:

```
sudo journalctl -f -u citadel
```

### Get container IP

To get the IP address of the container use:

```
docker inspect citadel | jq -r '.[]|"\(.NetworkSettings.Networks[].IPAddress|select(length > 0) // "# no ip address:")"'
```

Citadel Dashboard is accessible at http://172.17.0.2

### Shutdown Citadel

Inside the container:

```
shutdown now
```

Or from the host: 

```
docker stop citadel
```

## License

All code is licensed GPL v3
