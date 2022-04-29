# Citadel (Docker-in-Docker)

This installation method uses nested Docker containers for a lightweight and fast way to get up and running with Citadel.

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

```
docker run --runtime sysbox-runc -it --name citadel --hostname citadel citadel
```

Login in with the default Citadel credentials (user: _citadel_, password: _freedom_)

### Check Citadel startup logs

Citadel will startup automatically. Check the service logs with:

```
sudo journalctl -f -u citadel
```

### Get container IP

To get the IP address of the container from the host perspective use:

```
container_ip=$(docker inspect citadel | jq -r '.[]|"\(.NetworkSettings.Networks[].IPAddress|select(length > 0) // "# no ip address:")"');
echo "Citadel Dashboard is accessible at http://$container_ip"
```

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
