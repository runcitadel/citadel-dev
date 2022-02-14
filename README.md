# citadel-dev

Automatically initialize and manage a Citadel development environment.

## Install

### Clone with Git

```
git clone https://github.com/runcitadel/citadel-dev.git ~/.citadel-dev
```

### Update Shell Profile

```shell
export PATH="$PATH:$HOME/.citadel-dev/bin"
```

### Install Vagrant

Run `citadel-setup` if you're on debian/ubuntu based Linux, and you've already completed the above steps. It runs the following:

```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get -y install vagrant
vagrant plugin install vagrant-reload
```

### Install dependencies for vagrant-libvirt

Make sure your have all the build dependencies installed for
vagrant-libvirt. This depends on your distro. An overview:

- Ubuntu 18.10, Debian 9 and up:

```shell
apt-get build-dep vagrant ruby-libvirt
apt-get install qemu libvirt-daemon-system libvirt-clients ebtables dnsmasq-base
apt-get install libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev
apt-get install libguestfs-tools
```

- Ubuntu 18.04, Debian 8 and older:

```shell
apt-get build-dep vagrant ruby-libvirt
apt-get install qemu libvirt-bin ebtables dnsmasq-base
apt-get install libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev
apt-get install libguestfs-tools
```

(It is possible some users will already have libraries from the third line installed, but this is the way to make it work OOTB.)

- CentOS 6, 7, Fedora 21:

```shell
yum install qemu libvirt libvirt-devel ruby-devel gcc qemu-kvm libguestfs-tools
```

- Fedora 22 and up:

```shell
dnf install -y gcc libvirt libvirt-devel libxml2-devel make ruby-devel libguestfs-tools
```

- OpenSUSE leap 15.1:

```shell
zypper install qemu libvirt libvirt-devel ruby-devel gcc qemu-kvm libguestfs
```

- Arch Linux: please read the related [ArchWiki](https://wiki.archlinux.org/index.php/Vagrant#vagrant-libvirt) page.

```shell
pacman -S vagrant
```

Now you're ready to install vagrant-libvirt using standard [Vagrant plugin](http://docs.vagrantup.com/v2/plugins/usage.html) installation methods.

For some distributions you will need to specify `CONFIGURE_ARGS` variable before running `vagrant plugin install`:

- Fedora 32 + upstream Vagrant:
  ```shell
  export CONFIGURE_ARGS="with-libvirt-include=/usr/include/libvirt with-libvirt-lib=/usr/lib64"
  ```

### Install vagrant-libvirt

```shell
vagrant plugin install vagrant-libvirt
```

## Usage

```
$ citadel-dev
citadel-dev 1.2.1

Automatically initialize and manage an Citadel development environment.

Usage: citadel-dev <command> [options]

Commands:
    help                    Show this help message
    init                    Initialize an Citadel development environment in the working directory
    boot                    Boot the development VM
    shutdown                Shutdown the development VM
    destroy                 Destroy the development VM
    containers              List container services
    rebuild <container>     Rebuild a container service
    reload                  Reloads the Citadel service
    app <command> [options] Manages apps installations
    logs                    Stream Citadel logs
    run <command>           Run a command inside the development VM
    ssh                     Get an SSH session inside the development VM
    bitcoin-cli <command>   Run bitcoin-cli with arguments
    auto-mine <seconds>     Generate a block continuously
```

### Funding the Lightning wallet

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

## Troubleshooting

### Possible problems with vagant-libvert plugin installation on Linux

In case of problems with building nokogiri and ruby-libvirt gem, install
missing development libraries for libxslt, libxml2 and libvirt.

On Ubuntu, Debian, make sure you are running all three of the `apt` commands above with `sudo`.

On RedHat, Centos, Fedora, ...

```shell
$ sudo dnf install libxslt-devel libxml2-devel libvirt-devel ruby-devel gcc
```

On Arch Linux it is recommended to follow [steps from ArchWiki](https://wiki.archlinux.org/index.php/Vagrant#vagrant-libvirt).

If have problem with installation - check your linker. It should be `ld.gold`:

```shell
sudo alternatives --set ld /usr/bin/ld.gold
# OR
sudo ln -fs /usr/bin/ld.gold /usr/bin/ld
```

If you have issues building ruby-libvirt, try the following:

```shell
CONFIGURE_ARGS='with-ldflags=-L/opt/vagrant/embedded/lib with-libvirt-include=/usr/include/libvirt with-libvirt-lib=/usr/lib' GEM_HOME=~/.vagrant.d/gems GEM_PATH=$GEM_HOME:/opt/vagrant/embedded/gems PATH=/opt/vagrant/embedded/bin:$PATH vagrant plugin install vagrant-libvirt
```

### Additional Notes for Fedora and Similar Linux Distributions

If you encounter the following load error when using the vagrant-libvirt plugin (note the required by libssh):

```shell
/opt/vagrant/embedded/lib/ruby/2.4.0/rubygems/core_ext/kernel_require.rb:55:in `require': /opt/vagrant/embedded/lib64/libcrypto.so.1.1: version `OPENSSL_1_1_1b' not found (required by /lib64/libssh.so.4) - /home/xxx/.vagrant.d/gems/2.4.6/gems/ruby-libvirt-0.7.1/lib/_libvirt.so (LoadError)
```

then the following steps have been found to resolve the problem. Thanks to James Reynolds (see https://github.com/hashicorp/vagrant/issues/11020#issuecomment-540043472). The specific version of libssh will change over time so references to the rpm in the commands below will need to be adjusted accordingly.

```shell
# Fedora
dnf download --source libssh

# centos 8 stream, doesn't provide source RPMs, so you need to download like so
git clone https://git.centos.org/centos-git-common
# centos-git-common needs its tools in PATH
export PATH=$(readlink -f ./centos-git-common):$PATH
git clone https://git.centos.org/rpms/libssh
cd libssh
git checkout imports/c8s/libssh-0.9.4-1.el8
into_srpm.sh -d c8s
cd SRPMS

# common commands (make sure to adjust verison accordingly)
rpm2cpio libssh-0.9.0-5.fc30.src.rpm | cpio -imdV
tar xf libssh-0.9.0.tar.xz
mkdir build
cd build
cmake ../libssh-0.9.0 -DOPENSSL_ROOT_DIR=/opt/vagrant/embedded/
make
sudo cp lib/libssh* /opt/vagrant/embedded/lib64
```

If you encounter the following load error when using the vagrant-libvirt plugin (note the required by libk5crypto):

```shell
/opt/vagrant/embedded/lib/ruby/2.4.0/rubygems/core_ext/kernel_require.rb:55:in `require': /usr/lib64/libk5crypto.so.3: undefined symbol: EVP_KDF_ctrl, version OPENSSL_1_1_1b - /home/rbelgrave/.vagrant.d/gems/2.4.9/gems/ruby-libvirt-0.7.1/lib/_libvirt.so (LoadError)
```

then the following steps have been found to resolve the problem. After the steps below are complete, then reinstall the vagrant-libvirt plugin without setting the `CONFIGURE_ARGS`. Thanks to Marco Bevc (see https://github.com/hashicorp/vagrant/issues/11020#issuecomment-625801983):

```shell
# Fedora
dnf download --source krb5-libs

# centos 8 stream, doesn't provide source RPMs, so you need to download like so
git clone https://git.centos.org/centos-git-common
# centos-git-common needs its tools in PATH
export PATH=$(readlink -f ./centos-git-common):$PATH
git clone https://git.centos.org/rpms/krb5
cd krb5
git checkout imports/c8s/krb5-1.18.2-8.el8
into_srpm.sh -d c8s
cd SRPMS

# common commands (make sure to adjust verison accordingly)
rpm2cpio krb5-1.18-1.fc32.src.rpm | cpio -imdV
tar xf krb5-1.18.tar.gz
cd krb5-1.18/src
./configure
make
sudo cp -P lib/crypto/libk5crypto.* /opt/vagrant/embedded/lib64/
```

### VM Networking & Bridges

    - Useful Linux Utils
        - virsh
        - brctl
        - bridge-utils
    - Resources
        - https://jamielinux.com/docs/libvirt-networking-handbook/index.html
        - https://linuxconfig.org/how-to-use-bridged-networking-with-libvirt-and-kvm
        - https://wiki.libvirt.org/page/Networking

## Licenses

All code committed on and before git commit `874d4d801f1bb04ded5155e303be31fe20a17e63` is licensed via MIT and © Umbrel

All code committed after git commit `874d4d801f1bb04ded5155e303be31fe20a17e63` is licensed GPL v3
