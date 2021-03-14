#!/usr/bin/env bash
set -e

## Configure host to use timezone
## http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/set-time.html
#timezone=${TIME_ZONE:-America/Los_Angeles}
#
#echo "### Setting timezone to $timezone ###"
#sudo tee /etc/sysconfig/clock << EOF > /dev/null
#ZONE="$timezone"
#UTC=true
#EOF
#
#sudo ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
#
## Enable NTP
#sudo chkconfig ntpd on

#https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/set-time.html

echo "### Configuring the Amazon Time Sync Service on Amazon Linux AMI ###"

echo "### Connect to your instance and uninstall the NTP service. ###"
sudo yum erase 'ntp*'
#
echo "### Install the chrony package.###"
sudo yum install chrony
#
echo "### Restart the chrony daemon (chronyd). ###"
sudo service chronyd restart
#
echo "### Use the chkconfig command to configure chronyd to start at each system boot. ###"
sudo chkconfig chronyd on
#
echo "### Verify that chrony is using the 169.254.169.123 IP address to synchronize the time. ###"
chronyc sources -v
#
echo "### Verify the time synchronization metrics that are reported by chrony. ###"
chronyc tracking
