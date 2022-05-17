FROM debian@sha256:fbaacd55d14bd0ae0c0441c2347217da77ad83c517054623357d1f9d07f79f5e as systemd

#
# Systemd installation
#
RUN apt-get update &&                            \
    apt-get install -y --no-install-recommends   \
            systemd                              \
            systemd-sysv                         \
            libpam-systemd                       \
            libsystemd0                          \
            parted                               \
            ca-certificates                      \
            dbus                                 \
            iptables                             \
            iproute2                             \
            avahi-daemon                         \
            avahi-discover                       \
            libnss-mdns                          \
            kmod                                 \
            locales                              \
            sudo                                 \
            udev &&                              \
                                                 \
    # Prevents journald from reading kernel messages from /dev/kmsg
    echo "ReadKMsg=no" >> /etc/systemd/journald.conf &&               \
                                                                      \
    # Housekeeping
    apt-get clean -y &&                                               \
    rm -rf                                                            \
       /var/cache/debconf/*                                           \
       /var/lib/apt/lists/*                                           \
       /var/log/*                                                     \
       /tmp/*                                                         \
       /var/tmp/*                                                     \
       /usr/share/doc/*                                               \
       /usr/share/man/*                                               \
       /usr/share/local/* &&                                          \
                                                                      \
    # Create default user
    useradd --create-home --shell /bin/bash citadel &&                \
    echo "citadel:freedom" | chpasswd && adduser citadel sudo


FROM systemd as docker

# Docker install
RUN apt-get update && apt-get install --no-install-recommends -y      \
       apt-transport-https                                            \
       ca-certificates                                                \
       curl                                                           \
       gnupg                                                          \
       gnupg-agent                                                    \
       software-properties-common &&                                  \
                                                                      \
    curl -fsSL https://download.docker.com/linux/debian/gpg           \
         | apt-key add - &&                                           \
	                                                                  \
    apt-key fingerprint 0EBFCD88 &&                                   \
                                                                      \
    add-apt-repository                                                \
       "deb [arch=amd64] https://download.docker.com/linux/debian     \
       $(lsb_release -cs)                                             \
       stable" &&                                                     \
                                                                      \
    apt-get update && apt-get install --no-install-recommends -y      \
       docker-ce docker-ce-cli containerd.io &&                       \
                                                                      \
    # Housekeeping
    apt-get clean -y &&                                               \
    rm -rf                                                            \
       /var/cache/debconf/*                                           \
       /var/lib/apt/lists/*                                           \
       /var/log/*                                                     \
       /tmp/*                                                         \
       /var/tmp/*                                                     \
       /usr/share/doc/*                                               \
       /usr/share/man/*                                               \
       /usr/share/local/* &&                                          \
                                                                      \
    # Add user "citadel" to the Docker group
    usermod -a -G docker citadel

# Install Docker Compose V2
RUN mkdir -p /usr/local/lib/docker/cli-plugins/ &&                                                                  \
	curl -SL "https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-$(uname -s)-$(uname -m)"    \ 
         -o /usr/local/lib/docker/cli-plugins/docker-compose &&                                                     \
	chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Sshd install
RUN apt-get update && apt-get install --no-install-recommends -y      \
            openssh-server &&                                         \
    mkdir /home/citadel/.ssh &&                                       \
    chown citadel:citadel /home/citadel/.ssh


FROM docker as citadel

# Install Citadel
RUN apt-get update &&                                                          \
    apt-get install -y --no-install-recommends                                 \
            git                                                                \
            xxd                                                                \
            net-tools                                                          \
            vim                                                                \
            wget                                                               \
            fswatch                                                            \
            rsync                                                              \
            jq                                                                 \
            python3-dacite                                                     \
            python3-semver                                                     \
            python3-jsonschema                                                 \
            python3-yaml                                                       \
            python3-requests &&                                                \
                                                                               \
    git clone https://github.com/runcitadel/core.git /home/citadel/citadel &&  \
    chown -R 1000:1000 /home/citadel/citadel &&                                \
                                                                               \
    # Housekeeping
    apt-get clean -y &&                                                        \
    rm -rf                                                                     \
       /var/cache/debconf/*                                                    \
       /var/lib/apt/lists/*                                                    \
       /var/log/*                                                              \
       /tmp/*                                                                  \
       /var/tmp/*                                                              \
       /usr/share/doc/*                                                        \
       /usr/share/man/*                                                        \
       /usr/share/local/*

# Start Citadel with systemd
COPY citadel-startup.service /lib/systemd/system/
RUN ln -sf /lib/systemd/system/citadel-startup.service                         \
    /etc/systemd/system/multi-user.target.wants/citadel-startup.service

# Expose SSH and HTTP ports
EXPOSE 22
EXPOSE 80

# Make use of stopsignal (instead of sigterm) to stop systemd containers.
STOPSIGNAL SIGRTMIN+3

# Set systemd as entrypoint.
ENTRYPOINT [ "/sbin/init", "--log-level=err" ]
