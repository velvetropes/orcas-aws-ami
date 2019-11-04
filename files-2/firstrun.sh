#!/usr/bin/env bash
#cloud-boothook
# Configure Yum, the Docker daemon, and the ECS agent to use an HTTP proxy
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/http_proxy_config.html

# Specify proxy host, port number, and ECS cluster name to use

echo "ECS_CLUSTER=${ECS_CLUSTER}"

if grep -q 'Amazon Linux release 2' /etc/system-release ; then
    OS=AL2
    echo "### Setting OS to Amazon Linux 2"
elif grep -q 'Amazon Linux AMI' /etc/system-release ; then
    OS=ALAMI
    echo "### Setting OS to Amazon Linux AMI"
else
    echo "### ----->>> This user data script only supports Amazon Linux 2 and Amazon Linux AMI."
fi

# Set Yum HTTP proxy
if [[ -n $PROXY_URL ]]; then
    echo "### Set Yum HTTP proxy"
    echo "proxy=$PROXY_URL" >> /etc/yum.conf
    echo "$$: $(date +%s.%N | cut -b1-13)" > /var/lib/cloud/instance/sem/config_yum_http_proxy
fi

echo "### Set Docker HTTP proxy (different methods for Amazon Linux 2 and Amazon Linux AMI)"
# Set Docker HTTP proxy (different methods for Amazon Linux 2 and Amazon Linux AMI)
# Amazon Linux 2
if [ $OS == "AL2" ] && [[ -n $PROXY_URL ]]; then
    mkdir /etc/systemd/system/docker.service.d
    cat <<EOF > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=$PROXY_URL"
Environment="HTTPS_PROXY=$PROXY_URL"
Environment="NO_PROXY=169.254.169.254,169.254.170.2,email-smtp.us-west-2.amazonaws.com"
EOF
    systemctl daemon-reload
    if [ "$(systemctl is-active docker)" == "active" ]
    then
        systemctl restart docker
    fi
    echo "$$: $(date +%s.%N | cut -b1-13)" > /var/lib/cloud/instance/sem/config_docker_http_proxy
    echo "### FINISHED SETTING Docker HTTP proxy for Amazon Linux 2"

fi
# Amazon Linux AMI
if [ $OS == "ALAMI" ] && [[ -n $PROXY_URL ]]; then
    echo "export HTTP_PROXY=$PROXY_URL" >> /etc/sysconfig/docker
    echo "export HTTPS_PROXY=$PROXY_URL" >> /etc/sysconfig/docker
    echo "export NO_PROXY=169.254.169.254,169.254.170.2,email-smtp.us-west-2.amazonaws.com" >> /etc/sysconfig/docker
    echo "$$: $(date +%s.%N | cut -b1-13)" > /var/lib/cloud/instance/sem/config_docker_http_proxy
    echo "### FINISHED SETTING Docker HTTP proxy for Amazon Linux AMI"
fi

echo "### # Set ECS agent HTTP proxy"
# Set ECS agent HTTP proxy
if [[ -n $PROXY_URL ]]; then
    cat <<EOF > /etc/ecs/ecs.config
ECS_CLUSTER=$ECS_CLUSTER
ECS_LOGLEVEL=debug
HTTP_PROXY=$PROXY_URL
HTTPS_PROXY=$PROXY_URL
NO_PROXY=169.254.169.254,169.254.170.2,/var/run/docker.sock,email-smtp.us-west-2.amazonaws.com
EOF
    echo "$$: $(date +%s.%N | cut -b1-13)" > /var/lib/cloud/instance/sem/config_ecs-agent_http_proxy
else
    cat >> /etc/ecs/ecs.config <<EOF
ECS_CLUSTER=$ECS_CLUSTER
ECS_LOGLEVEL=debug
EOF
fi

echo "### Setting ecs-init HTTP proxy"
# Set ecs-init HTTP proxy (different methods for Amazon Linux 2 and Amazon Linux AMI)
# Amazon Linux 2
if [ $OS == "AL2" ] && [[ -n $PROXY_URL ]]; then
    mkdir /etc/systemd/system/ecs.service.d
    cat <<EOF > /etc/systemd/system/ecs.service.d/http-proxy.conf
[Service]
Environment=HTTP_PROXY=$PROXY_URL
Environment HTTPS_PROXY=$PROXY_URL
Environment="NO_PROXY=169.254.169.254,169.254.170.2,/var/run/docker.sock,email-smtp.us-west-2.amazonaws.com"
EOF
    systemctl daemon-reload
    if [ "$(systemctl is-active ecs)" == "active" ]; then
        systemctl restart ecs
    fi
    echo "$$: $(date +%s.%N | cut -b1-13)" > /var/lib/cloud/instance/sem/config_ecs-init_http_proxy
    echo "### Set ecs-init HTTP proxy for Amazon Linux 2"
fi
# Amazon Linux AMI
if [ $OS == "ALAMI" ] && [[ -n $PROXY_URL ]]; then
    cat <<EOF > /etc/init/ecs.override
env HTTP_PROXY=$PROXY_URL
env HTTPS_PROXY=$PROXY_URL
env NO_PROXY=169.254.169.254,169.254.170.2,/var/run/docker.sock,email-smtp.us-west-2.amazonaws.com
EOF
    echo "$$: $(date +%s.%N | cut -b1-13)" > /var/lib/cloud/instance/sem/config_ecs-init_http_proxy
    echo "### Set ecs-init HTTP proxy for Amazon Linux AMI"
fi

echo "### Write AWS Logs region"
# Write AWS Logs region
sudo tee /etc/awslogs/awscli.conf << EOF > /dev/null
[plugins]
cwlogs = cwlogs
[default]
region = ${AWS_DEFAULT_REGION}
EOF

# Write AWS Logs config
sudo tee /etc/awslogs/awslogs.conf << EOF > /dev/null
[general]
state_file = /var/lib/awslogs/agent-state

[/var/log/dmesg]
file = /var/log/dmesg
log_group_name = ${STACK_NAME}/ec2/${AUTOSCALING_GROUP}/var/log/dmesg
log_stream_name = {instance_id}

[/var/log/messages]
file = /var/log/messages
log_group_name = ${STACK_NAME}/ec2/${AUTOSCALING_GROUP}/var/log/messages
log_stream_name = {instance_id}
datetime_format = %b %d %H:%M:%S

[/var/log/docker]
file = /var/log/docker
log_group_name = ${STACK_NAME}/ec2/${AUTOSCALING_GROUP}/var/log/docker
log_stream_name = {instance_id}
datetime_format = %Y-%m-%dT%H:%M:%S.%f

[/var/log/ecs/ecs-init.log]
file = /var/log/ecs/ecs-init.log*
log_group_name = ${STACK_NAME}/ec2/${AUTOSCALING_GROUP}/var/log/ecs/ecs-init
log_stream_name = {instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ
time_zone = UTC

[/var/log/ecs/ecs-agent.log]
file = /var/log/ecs/ecs-agent.log*
log_group_name = ${STACK_NAME}/ec2/${AUTOSCALING_GROUP}/var/log/ecs/ecs-agent
log_stream_name = {instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ
time_zone = UTC
EOF

echo "#### Start services ####"
# Start services
#sudo service awslogs start
echo "### aws logs"
sudo systemctl start awslogsd
sudo systemctl enable awslogsd.service
sudo systemctl status awslogsd

echo "### docker"
#sudo chkconfig docker on
sudo systemctl status docker
#sudo systemctl restart docker

echo "### ecs"
echo "### To install the Amazon ECS container agent on an Amazon Linux 2 EC2 instance"
sudo amazon-linux-extras disable docker
sudo amazon-linux-extras install -y ecs
sudo amazon-linux-extras install -y ecs; sudo systemctl enable --now ecs

echo curl -s http://localhost:51678/v1/metadata | python -mjson.tool

echo "### Enable the ecs Amazon Linux extra repository."
sudo systemctl start ecs
sudo systemctl enable --now ecs
sudo systemctl status ecs

# Exit gracefully if ECS_CLUSTER is not defined
if [[ -z ${ECS_CLUSTER} ]]
  then
  echo "Skipping ECS agent check as ECS_CLUSTER variable is not defined"
  exit 0
fi

# Loop until ECS agent has registered to ECS cluster
echo "Checking ECS agent is joined to ${ECS_CLUSTER}"
until [[ "$(curl --fail --silent http://localhost:51678/v1/metadata | jq '.Cluster // empty' -r -e)" == ${ECS_CLUSTER} ]]
  do printf '.'
  sleep 5
done
echo "ECS agent successfully joined to ${ECS_CLUSTER}"
