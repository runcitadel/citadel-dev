FROM debian:11

RUN set -eux; \
	apt update; \
	apt install -y --no-install-recommends \
		ca-certificates \
		iptables \
		openssl \
		pigz \
		xz-utils \
		sudo \
		iproute2 \
		curl \
		wget \
		git \
	;
	# rm -rf /var/lib/apt/lists/*

ENV DOCKER_TLS_CERTDIR=/certs
RUN mkdir /certs /certs/client && chmod 1777 /certs /certs/client

COPY --from=docker:20.10.5-dind /usr/local/bin/ /usr/local/bin/

VOLUME /var/lib/docker

# Install Compose V2
RUN mkdir -p /usr/local/lib/docker/cli-plugins/
RUN curl -SL https://github.com/docker/compose/releases/download/v2.4.1/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
RUN chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Install Citadel
RUN apt install -y fswatch rsync jq python3-dacite python3-semver python3-jsonschema python3-yaml python3-requests
RUN git clone https://github.com/runcitadel/core.git ./citadel
RUN sudo NETWORK=regtest /citadel/scripts/configure
# RUN cd /citadel/core/; \
# 	docker compose up --detach --build --remove-orphans

ENTRYPOINT ["dockerd-entrypoint.sh"]
CMD []
# CMD cd /citadel/core/; docker compose up --detach --build --remove-orphans
