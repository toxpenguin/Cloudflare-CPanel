#!/bin/bash

#
# CloudFlare cPanel Update Script
#

FORCE_INSTALL=false
HOST_KEY=""

while getopts ":f" opt; do
    case $opt in
        f)
            FORCE_INSTALL=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Get the host key
HOST_KEY=`cat /root/.cpanel/datastore/cf_api`

# Check HOST_KEY exists
if [ "$HOST_KEY" = "" ]; then
    echo "ERROR - Missing HOST_KEY"
    exit 1
fi

# Get the version of the plugin currently installed on the server
INSTALLED_VERSION=`cat /usr/local/cpanel/base/frontend/jupiter/cloudflare/composer.json | grep version | cut -d "\"" -f 4`

# What is the latest version of the plugin that is available
CURRENT_VERSION=$(curl --silent "https://api.github.com/repos/toxpenguin/CloudFlare-CPanel/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | cut -d"v" -f2)

# Is CURRENT_VERSION > INSTALLED_VERSION
NEW_VERSION=`echo $INSTALLED_VERSION $CURRENT_VERSION | awk '{ print ($1 < $2) ? 0 : 1 }'`

if [[ "$NEW_VERSION" == 0 || "$FORCE_INSTALL" == true ]]
    then
        curl -s -L -o ./cloudflare.install.sh "https://raw.githubusercontent.com/toxpenguin/CloudFlare-CPanel/main/cloudflare.install.sh"
        chmod 0700 ./cloudflare.install.sh
        bash cloudflare.install.sh -k $HOST_KEY -n ' '
fi

