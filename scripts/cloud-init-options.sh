#!/usr/bin/env bash
set -e

# Disable cloud-init repo updates or upgrades
# because it's part of the cloud init network
#
# Default config is to run yum package update before user data is invoked
# problem when in private network
# also will slow down the start up time if we don't disable this
sudo sed -i -e '/^repo_update: /{h;s/: .*/: false/};${x;/^$/{s//repo_update: false/;H};x}' /etc/cloud/cloud.cfg
sudo sed -i -e '/^repo_upgrade: /{h;s/: .*/: none/};${x;/^$/{s//repo_upgrade: none/;H};x}' /etc/cloud/cloud.cfg
