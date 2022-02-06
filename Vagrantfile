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
  config.vm.synced_folder ".", "/vagrant"

  # Update package lists
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
  SHELL

  # Install Docker
  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get install -y curl python3-pip libffi-dev
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker vagrant
    pip3 install docker-compose
  SHELL

  # Todo: not sure what Avahi was being used for?
  # Install Avahi
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get install -y avahi-daemon avahi-discover libnss-mdns
  # SHELL

  # Install Citadel
  config.vm.provision "shell", inline: <<-SHELL
    apt-get install -y fswatch rsync jq
    cd /vagrant/runcitadel/core
    sudo NETWORK=regtest ./scripts/configure
    docker-compose build --parallel
    docker-compose run dashboard -c yarn
  SHELL

  # Start Citadel on boot
  config.vm.provision "shell", run: 'always', inline: <<-SHELL
    cd /vagrant/runcitadel/core
    sudo chown -R 1000:1000 .
    chmod -R 700 tor/data/*
    ./scripts/start
  SHELL

  # Message
  config.vm.post_up_message = "\n\nCitadel development environment ready: http://#{config.vm.hostname}.local"
end
