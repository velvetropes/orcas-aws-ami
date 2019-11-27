#!/usr/bin/env bash
set -e

# Disable the docker Amazon Linux extra repository. The ecs Amazon Linux extra repository ships with its own version of Docker, so the docker extra must be disabled to avoid any potential future conflicts. This ensures that you are always using the Docker version that Amazon ECS intends for you to use with a particular version of the container agent.
sudo amazon-linux-extras disable docker

# Install and enable the ecs Amazon Linux extra repository.
sudo amazon-linux-extras install -y ecs; sudo systemctl enable --now ecs

# Additional operating system packages
packages="awslogs jq aws-cfn-bootstrap"

# Exclude Docker and ECS Agent from update
sudo yum -y -x docker\* -x ecs\* update

echo "### Installing extra packages: $packages ###"
sudo yum -y install $packages 