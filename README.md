# Citadel (Docker-in-Docker)

## Install

### Clone with Git

```
git clone https://github.com/runcitadel/citadel-dev.git#docker-in-docker
```

### Build the image

```
docker build -t citadel .
```

### Run Container

Run the container in priviledged mode and give it a hostname

```
docker run --privileged -d --name citadel --hostname citadel citadel
```

### Start Citadel

```
docker exec -it citadel sudo /citadel/scripts/start
```

### Get container IP

```
docker inspect citadel | jq -r '.[]|"\(.NetworkSettings.Networks[].IPAddress|select(length > 0) // "# no ip address:")"'
```

Citadel Dashboard is accessible at http://172.17.0.2

## License

All code is licensed GPL v3
