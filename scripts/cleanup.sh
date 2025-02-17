#!/usr/bin/env bash
set -e

echo "### Performing final clean-up tasks ###"
sudo service docker stop

sudo chkconfig docker off
sudo rm -f /var/log/docker /var/log/ecs/*


# An intermittent failure scenario sees this created as a directory when the
# ECS agent attempts to map it into its container, so do rm -Rf just in case
# 8/18 This is needed for host  mode, but we use network so let's not get rid of it
sudo rm -Rf /var/run/docker.sock

# Remove Docker network database
# 8/18 This is needed for host  mode, but we use network so let's not get rid of it
sudo rm -rf /var/lib/docker/network

# Remove docker0 interface if it has been created
# 8/18 This is needed for host  mode, but we use network so let's not get rid of it
sudo ip link del docker0 || true
