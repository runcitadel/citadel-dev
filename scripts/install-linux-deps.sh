#!/bin/bash

# check if sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please re-run this script as root: \"sudo ./$(basename $BASH_SOURCE)\""
    exit
fi

# check if ifconfig is installed
if command -v "ifconfig" >/dev/null 2>&1; then
    echo 'ifconfig is already installed. Skipping...'
  else
    echo 'Installing ifconfig (via net-tools)...'
    if [ -f /etc/redhat-release ] ; then
      dnf install net-tools
    elif [ -f /etc/debian_version ] ; then
      apt update
      apt install net-tools

    # Todo: Should we support other linux flavors?
    # elif [ -f /etc/SuSE-release ] ; then # I think openSUSE may have ifconfig installed out of the box
    # elif [ -f /etc/mandrake-release ] ; then # Not sure about Mandrake?
    fi
fi