#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<EOF
${CLI_NAME}-cli v${CLI_VERSION}
Automatically initialize and manage isolated Citadel instances.

Usage: ${CLI_NAME} <command> [options]

Flags:
    -h, --help                         Show this help message
    -v, --version                      Show version information for this CLI

Commands:
    install                            Builds the image and installs Docker + Sysbox
    dev [options]                      Initialize a development environment
    boot [options]                     Run a new container
    start                              Start the container
    stop                               Stop the container
    list                               List all Citadel containers with their status in a table format
    ssh                                Get an SSH session inside a container
    info                               Show information about a container
    reload                             Reload the Citadel service
    backup                             Backup the container
    restore <path>                     Restore a backup
    destroy                            Destroy a container
    run <command>                      Run a command inside the container
    containers                         List container services
    rebuild <container>                Rebuild a container service
    app <command> [options]            Manages apps installations
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

  if ${5}; then
    cat <<EOF
Citadel started in development mode with Bitcoin network set to ${4}.

Yarn is installing dependencies and spinning up development servers.
Run \`${CLI_NAME} logs dashboard manager middleware\` to see progress.

URLs:

 - Dashboard (current) 

      Local:    http://${1}.local
      Network:  http://${2}:${3}

 - Dashboard (new)     

      Local:    http://${1}.local:8000
      Network:  not available

--------------------------------------------------------------------------------
EOF
  else
    cat <<EOF
Citadel is running with Bitcoin network set to ${4}.

Dashboard listening at:

  - Local:    http://${1}.local
  - Network:  http://${2}:${3}

--------------------------------------------------------------------------------
EOF
  fi
}

show_info() {
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

 Name: ${1}
 Status: ${2}
 Network: ${6}

 - Dashboard 

      Local:    http://${1}.local
      Network:  http://${3}:${4}

 - SSH

      Local:    ssh citadel@${1}.local
      Network:  ssh citadel@${3} -p ${5}

--------------------------------------------------------------------------------
EOF
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
  # move up from scripts folder
  echo "$dir/.."
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
    # TODO:
    echo 'citadel'
  fi
}

get_host_ip() {
  # Get the first non-localhost and non-IPv6 IP of the host with unknown network interfaces
  echo $(ip addr show | grep "inet " | grep -v 127.0.0. | head -1 | cut -d" " -f6 | cut -d/ -f1)
}

get_container_hostname() {
  echo $(docker container inspect --format='{{.Config.Hostname}}' $1)
}

get_container_port_http() {
  echo $(docker container inspect --format='{{(index (index .NetworkSettings.Ports "80/tcp") 0).HostPort}}' $1)
}

get_container_port_ssh() {
  echo $(docker container inspect --format='{{(index (index .NetworkSettings.Ports "22/tcp") 0).HostPort}}' $1)
}

# Check configured Bitcoin network directly from container .env
get_node_network() {
  if [ -z ${1+x} ]; then
    target_container=$(get_container_name)
  else
    target_container=$1
  fi

  network_line=$(run_in_container "cat .env | grep BITCOIN_NETWORK" $target_container)
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
  if [ -z ${2+x} ]; then
    target_container=$(get_container_name)
  else
    target_container=$2
  fi

  docker exec -t $target_container bash -c "cd /home/citadel/citadel && $1"
}

# Check if Dashboard is running
wait_for_dashboard() {
  if [ -z ${1+x} ]; then
    target_container=$(get_container_name)
  else
    target_container=$1
  fi

  while true; do
    run_in_container "docker logs dashboard" $target_container &>/dev/null || {
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
