#!/bin/bash

# check if sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please re-run this script as root: \"sudo ./$(basename $BASH_SOURCE)\""
    exit
fi

# check if installed
if command -v "docker" >/dev/null 2>&1; then
    echo 'Error: the "docker" command appears to already exist on this system.'
    exit 1
fi

# install
curl -fsSL https://get.docker.com | sudo sh
