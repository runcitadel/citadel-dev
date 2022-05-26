#!/bin/bash

# check if sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please re-run this script as root: \"sudo ./$(basename $BASH_SOURCE)\""
    exit
fi

# check if installed
if command -v "sysbox" >/dev/null 2>&1; then
    echo 'Error: the "sysbox" command appears to already exist on this system.'
    exit 1
fi

# confirm
printf "\n# ATTENTION: This script will build Sysbox from source which can take a long time.\n"
echo "To get the packaged version for your system see installation instructions at"
echo "https://github.com/nestybox/sysbox/blob/master/docs/user-guide/install-package.md"
read -p "Do you want to continue? [y/N] " should_start
if [[ ! $should_start =~ [Yy]$ ]]; then
    exit
fi

# configure git
git config --global url.https://github.com/.insteadOf git@github.com:

# install sysbox
git clone --recursive git@github.com:nestybox/sysbox.git
cd sysbox
make sysbox
sudo make install

# start sysbox
sudo ./scr/sysbox

# configure docker
sudo ./scr/docker-cfg --sysbox-runtime=enable

# cleanup
git config --global --unset-all url.https://github.com/.insteadof
