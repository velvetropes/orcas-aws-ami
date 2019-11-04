#!/usr/bin/env bash
set -e

# Additional operating system packages
packages="awslogs jq aws-cfn-bootstrap"

# Exclude Docker and ECS Agent from update
sudo yum -y -x docker\* -x ecs\* update --verbose

echo "### Disable the docker Amazon Linux extra repository."
sudo amazon-linux-extras disable docker

echo "### Install and enable the ecs Amazon Linux extra repository."
sudo amazon-linux-extras install -y ecs
sudo systemctl enable --now ecs

echo "### Installing extra packages: $packages ###"
sudo yum -y install $packages  --verbose
