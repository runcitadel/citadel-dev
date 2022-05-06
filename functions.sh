#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<EOF
${CLI_NAME} 1.3.0

Automatically initialize and manage isolated Citadel instances.

Usage: ${CLI_NAME} <command> [options]

Commands:
    help                               Show this help message
    install                            Builds the image and installs Docker + Sysbox
    dev [options]                      Initialize a development environment
    boot [options]                     Run a new container
    start                              Start the container
    stop                               Stop the container
    reload                             Reloads the Citadel service
    backup                             Backup the container
    restore <path>                     Restore a backup
    destroy                            Destroy the container
    ssh <command>                      Get an SSH session inside the container
    run <command>                      Run a command inside the container
    containers                         List container services
    rebuild <container>                Rebuild a container service
    app <command> [options]            Manages apps installations
    bitcoin-cli <command>              Run bitcoin-cli with arguments
    lncli <command>                    Run lncli with arguments
    fund <amount>                      Fund the onchain wallet (regtest mode only)
    auto-mine <seconds>                Generate a block continuously (regtest mode only)
    logs                               Stream Citadel logs
EOF
}

show_welcome() {
  cat <<EOF

                                    *(#%%(*                                     
                              **/(###(/#&&&%#(/**                               
                           *(((((//*,,,#@@@@&&&%#((*                            
                         */(%(**,,,,,,,#@@@@@@@@@%(/                            
                         */(%/,,,,,,,,,#@@@@@@@@@%(*                            
             **/(##/*,,,,*/(%/,,,**/(#%%&&&&@@@@@%(*,,,,,*/#&%(/**              
         */(((((/*,,,,,,,*(##(/(##%%%#(%&&&&&&&&&%(/**,,,/(%@@&&&%#(/*      
     */(%%#(**,,,,,,,*/(#%&&&&&%%#(/**,#@@@&&&&&&&&&&%#(//(%@@@@@@@&%%%(**      
     (%&&&%%%(*,,,,/(%&&&&&&&#/*,,,,,,,#@@@@@@@&&&&&&&&&&&%&@@@@&&%%%(/*,*      
     (%&@@@@&&&%#(/#%&&%%#/*,,,,,,,,,,,#@@@@@@@@@@@&&&&&&&%&&%%##(/*,,,,,*      
     (%&@@@@@@@@&&%#((/*,,,,,,,,,,,,,,,#@@@@@@@@@@@@@@@@&&&%%(/*,,,,,,,,,*      
     (%&@@@@@@@@@&#/,,,,,,,,,,,,,,,,,,,#@@@@@@@@@@@@@@@@@@@%(/,,,,,,,,,,,*      
     (%&@@@@@@@@@&#(/**,,,*(%##/,,,,,,,#@@@@@@@&%%%&&@@@@&&%(/,,,,,,,,,,,*      
     (%&@@@@@@@@@&###%&%#((%@&&&&%(/**,#@@@&%%%#(*,(%%%&&&%#(/,,,,,,,,,,,*      
     (%&@@@@@@@@@@&%%&&&&&%&@@@@@@&&&%##%##(/*,,,,,/%%&&&%#(**,,,,,,,,,,,*      
     (%&@@@@@@@@@@@@@@@&%%%&@@@@@@@@@@@#**,,,,,,,,,/%%%(/**,,,,,,,,,,,,,,*      
     (%&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,*      
     (%&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,*      
     (%&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,*      
     (%&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,*      
     (%&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,*      
     /%&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,*      
     *(%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,*      
       #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,*      
       */#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,*        
         */#&&@@@@@@@@@@@@@@@@@@@@@@@@@#,,,,,,,,,,,,,,,,,,,,,,,,,,,*           
            */(#%&@@@@@@@@@@@@@@@@@@@@@#,,,,,,,,,,,,,,,,,,,,,,,,*              
                **/(%&@@@@@@@@@@@@@@@@@#,,,,,,,,,,,,,,,,,,,,,*                 
                      *(%&@@@@@@@@@@@@@#,,,,,,,,,,,,,,,,,,*                    
                         **(%%&@@@@@@@@#,,,,,,,,,,,,,,*                        
                             **(#%&@@@@#,,,,,,,,,,,*                           
                                  */(#&#,,,,,,,*
                                      *#,,,*                               

--------------------------------------------------------------------------------

EOF

  if ${4}; then
    cat <<EOF
Citadel started in development mode with Bitcoin network set to ${1}.

Yarn is installing dependencies and spinning up development servers.
Run "citadel-dev logs dashboard manager middleware" to see progress.

URLs:

 - dashboard (current)  http://${2}.local
                        http://${3}

 - dashboard (new)      http://${2}.local:8000
                        http://${3}:8000

--------------------------------------------------------------------------------
EOF
  else
    cat <<EOF
Citadel is running with Bitcoin network set to ${1}.

Dashboard is listening at:

  - http://${2}.local
  - http://${3}

--------------------------------------------------------------------------------
EOF
  fi
}

# Get script location and correctly handle any symlinks
get_script_location() {
  source="${BASH_SOURCE[0]}"
  # Resolve $source until the file is no longer a symlink
  while [ -h "$source" ]; do
    dir="$(cd -P "$(dirname "$source")" >/dev/null 2>&1 && pwd)"
    source="$(readlink "$source")"
    # If $source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    [[ $source != /* ]] && source="$dir/$source"
  done
  dir="$(cd -P "$(dirname "$source")" >/dev/null 2>&1 && pwd)"
  echo $dir
}

# Check if required dependencies are installed
check_dependencies() {
  for cmd in "git" "docker" "sysbox"; do
    if ! command -v $cmd >/dev/null 2>&1; then
      echo "This script requires Git, Docker and Sysbox to be installed."
      echo
      echo "See:"
      echo "  - Git: https://git-scm.com/downloads"
      echo "  - Docker: https://docs.docker.com/get-docker/"
      echo "  - Sysbox: https://github.com/nestybox/sysbox/blob/master/docs/user-guide/install-package.md"
      echo
      echo "or run \"$CLI_NAME install\""
      exit 1
    fi
  done
}

check_dev_environment() {
  if [ -f "$PWD/.citadel-dev" ]; then
    echo true
  else
    echo false
  fi
}

get_container_ip() {
  echo $(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)
}

get_container_hostname() {
  echo $(docker inspect --format='{{.Config.Hostname}}' $CONTAINER_NAME)
}

# Check if container exists
check_container() {
  docker container inspect $CONTAINER_NAME &>/dev/null || {
    echo "No container found."
    exit 1
  }
}

# Check configured Bitcoin network directly from container
get_node_network() {
  network_line=$(run_in_container "cat .env | grep BITCOIN_NETWORK")
  network=${network_line:16}
  echo $(trim $network)
}

# Check that network is regtest
check_node_network() {
  network=$(get_node_network)

  if [[ ! "$network" == *"regtest"* ]]; then
    echo "This command only works on regtest."
    exit 1
  fi
}

# Run a command inside the container
run_in_container() {
  docker exec -t $CONTAINER_NAME bash -c "cd /home/citadel/citadel && $1"
}

# Check if Dashboard is running
wait_for_dashboard() {
  while true; do
    run_in_container "docker logs dashboard" &>/dev/null || {
      # echo "Dashboard is not running. Trying again in 5 seconds..."
      sleep 5
      continue
    }

    break
  done
}
