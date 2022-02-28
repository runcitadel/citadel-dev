Vagrant.configure(2) do |config|

  # Name Vagrant machine
  config.vm.define "citadel"

  # Specify OS
  config.vm.box = "generic/debian11"

  # Set hostname
  config.vm.hostname = "citadel-dev"

  # Todo: bridge not working...
  # config.vm.network "public_network", bridge: "virbr0" # Bridge machine to host network
  # Bridge machine to host network with Ruby
  # config.vm.network "public_network", bridge: "#$default_network_interface"

  # Sync files from host
  # NOTE:
  # - set NFS version
  # - set map_uid/map_gid to avoid permission errors
  config.vm.synced_folder ".",
    "/vagrant",
    id: "core",
    type: "nfs",
    nfs_version: "4",
    nfs_udp: false,
    map_uid: 0, map_gid: 0

  # Update package lists
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
  SHELL

  # Install Docker
  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get install -y curl libffi-dev
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker vagrant

    # Install Compose V2
    mkdir -p /usr/local/lib/docker/cli-plugins/
    curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
  SHELL

  # Install Avahi
  config.vm.provision "shell", inline: <<-SHELL
    apt-get install -y avahi-daemon avahi-discover libnss-mdns
  SHELL

  # Install Citadel
  config.vm.provision "shell", env: {"NETWORK" => ENV['NETWORK']}, inline: <<-SHELL
    apt-get install -y fswatch rsync jq python3-dacite python3-semver python3-jsonschema python3-yaml
    cd /vagrant/runcitadel/core
    sudo NETWORK=$NETWORK ./scripts/configure
    docker compose build --parallel
  SHELL

  # Start Citadel on boot
  config.vm.provision "shell", run: 'always', inline: <<-SHELL
    cd /vagrant/runcitadel/core
    sudo chown -R 1000:1000 .
    chmod -R 700 tor/data/*
    ./scripts/start
  SHELL

# Message
$msg = <<MSG
-----------------------------------------------------------
Citadel development environment ready:

Network: #{ENV['NETWORK']}

URLs:
 - dashboard (current)  - http://#{config.vm.hostname}.local
 - dashboard (new)      - http://#{config.vm.hostname}.local:8000

-----------------------------------------------------------
MSG

  config.vm.post_up_message = $msg
end
