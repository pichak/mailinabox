#!/bin/bash

# This script is used within containers to turn it into a Mail-in-a-Box.
# It is referenced by the Dockerfile. You should not run it directly.
########################################################################

# Local configuration details were not known at the time the Docker
# image was created, so all setup is defered until the container
# is started. That's when this script runs.

# If we're not in an interactive shell, set defaults.
if [ ! -t 0 ]; then
	export PUBLIC_IP=auto
	export PUBLIC_IPV6=auto
	export PRIMARY_HOSTNAME=auto
	export CSR_COUNTRY=US
	export NONINTERACTIVE=1
fi

# Start configuration.
rsyslogd

cd /usr/local/mailinabox
export IS_DOCKER=1
export STORAGE_ROOT=/data
export STORAGE_USER=user-data
export DISABLE_FIREWALL=1
source setup/start.sh # using 'source' means an exit from inside also exits this script and terminates container

exec /sbin/my_init -- bash
