#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<EOF
${CLI_NAME} ${CLI_VERSION}

Automatically initialize and manage isolated Citadel instances.

Usage: ${CLI_NAME} <command> [options]

Commands:
    help                               Show this help message
    install                            Builds the image and installs Docker + Sysbox
    dev [options]                      Initialize a development environment
    boot [options]                     Run a new container
    list                               List all Citadel containers with their status in a table format
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
    fund <amount>                      Fund the onchain wallet (regtest mode only)
    auto-mine <seconds>                Generate a block continuously (regtest mode only)
    logs                               Stream Citadel logs
    version                            Show version information for this CLI
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
Run \`${CLI_NAME} logs dashboard manager middleware\` to see progress.

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

Dashboard listening at:

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
    dir="$(cd -P "$(dirname "$source")" 2>&1 && pwd)"
    source="$(readlink "$source")"
    # If $source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    [[ $source != /* ]] && source="$dir/$source"
  done
  dir="$(cd -P "$(dirname "$source")" 2>&1 && pwd)"
  # move up from scripts folder
  echo "$dir/.."
}

# Check if required dependencies are installed
check_dependencies() {
  for cmd in "git" "docker" "sysbox-runc"; do
    if ! command -v $cmd 2>&1; then
      echo "This script requires Git, Docker and Sysbox to be installed."
      echo
      echo "See:"
      echo "  - Git: https://git-scm.com/downloads"
      echo "  - Docker: https://docs.docker.com/get-docker/"
      echo "  - Sysbox: https://github.com/nestybox/sysbox/blob/master/docs/user-guide/install-package.md"
      echo
      echo "or run \`$CLI_NAME install\`"
      exit 1
    fi
  done
}

check_container_exists() {
  docker container inspect $1 &>/dev/null || {
    echo "No container found with name or ID \"$1\"."
    exit 1
  }
}

check_container_running() {
  status=$(docker container inspect -f '{{.State.Status}}' $1)

  if [[ ! $(trim $status) == "running" ]]; then
    echo "Container \"$1\" is not running."
    exit 1
  fi
}

# Check if container name is unambiguous
check_container_name() {
  is_dev_env=$(is_dev_environment)
  is_multiple=$(check_multiple)

  if $is_dev_env; then
    if [ -s "$PWD/.citadel-dev" ]; then
      return
    else
      echo "No container found for this environment. Try booting with \`citadel boot\`."
      exit 1
    fi
  fi

  return

  # TODO: enable multiple
  #   if ! $is_multiple; then
  #     docker ps --all --filter "ancestor=$IMAGE_NAME" --format '{{.Names}}' || {
  #       exit 1
  #     }
  #   else
  #     cat >&2 <<EOF
  # More than one instance of Citadel found on your system.
  # Either run this command again from a Citadel environment
  # or specify a target container. Run \`citadel list\`
  # to get an ID or name of a target container.
  # EOF
  #     exit 1
  #   fi
}

check_multiple() {
  containers=($(docker ps --all --filter "ancestor=$IMAGE_NAME" --format '{{.Names}}'))

  if [[ ${#containers[@]} -gt 1 ]]; then
    echo true
  else
    echo false
  fi
}

is_dev_environment() {
  if [ -f "$PWD/.citadel-dev" ]; then
    echo true
  else
    echo false
  fi
}

get_container_name() {
  is_dev_env=$(is_dev_environment)
  # is_multiple=$(check_multiple)

  if $is_dev_env; then
    cat "$PWD/.citadel-dev"
  else
    echo 'citadel'
  fi
}

get_container_ip() {
  echo $(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(get_container_name))
}

get_container_hostname() {
  echo $(docker inspect --format='{{.Config.Hostname}}' $(get_container_name))
}

# Check configured Bitcoin network directly from container
get_node_network() {
  network_line=$(run_in_container "cat .env | grep BITCOIN_NETWORK")
  network=${network_line:16}
  echo $(trim $network)
}

# Check that command was called from a dev environment
check_dev_environment() {
  is_dev_env=$(is_dev_environment)

  if ! $is_dev_env; then
    echo "This command only works for Citadel development environments right now."
    exit 1
  fi
}

# Check that network is regtest
check_node_network() {
  network=$(get_node_network)

  if [[ ! "$network" == *"regtest"* ]]; then
    echo "This command only works in regtest mode."
    exit 1
  fi
}

# Run a command inside the container
run_in_container() {
  docker exec -t $(get_container_name) bash -c "cd /home/citadel/citadel && $1"
}

# Check if Dashboard is running
wait_for_dashboard() {
  # TOOD: fix for multiple prod
  while true; do
    run_in_container "docker logs dashboard" &>/dev/null || {
      # echo "Dashboard is not running. Trying again in 5 seconds..."
      sleep 5
      continue
    }

    break
  done
}

# Check if inner container is running
check_inner_container() {
  status=$(run_in_container "docker container inspect -f '{{.State.Status}}' $1")

  if [[ ! $(trim $status) == "running" ]]; then
    echo "Container \"$1\" is not running."
    exit 1
  fi
}

# Run bitcoin-cli with arguments
bitcoin_cli() {
  check_dependencies
  check_container_name

  if [ -z ${2+x} ]; then
    args=""
  else
    args="${@:2}"
  fi
  run_in_container "docker exec -t bitcoin bitcoin-cli ${args}"
  exit
}

# Run lncli with arguments
lncli() {
  check_dependencies
  check_container_name

  if [ -z ${2+x} ]; then
    args=""
  else
    args="${@:2}"
  fi

  run_in_container "docker exec -t lightning lncli ${args}"
  exit
}
