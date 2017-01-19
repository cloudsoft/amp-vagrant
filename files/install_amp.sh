#!/bin/bash

# Exit script on error
set -e

# Set Java Vars
JAVA_VERSION=8
export JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64/

echo "Download AMP"
curl -o cloudsoft-amp-karaf-noarch.rpm -s -S http://downloads.cloudsoftcorp.com/amp/latest/cloudsoft-amp-karaf-latest-noarch.rpm

echo "Validate downloaded file is an archive"
download_type=`file cloudsoft-amp-karaf-noarch.rpm`

if ! (echo $download_type | grep 'RPM .* bin noarch') > /dev/null ; then
  cat >&2 <<EOL
ERROR - Downloaded AMP RPM is not a valid RPM binary package - please contact Cloudsoft support
ERROR - who will assist you further. Type: ${download_type}
ERROR -
EOL
  exit 1
fi

echo "Restarting Syslog"
sudo systemctl restart rsyslog

echo "Updating Yum"
sudo yum -y update

echo "Install Java"
sudo yum install -y java-1.8.0-openjdk-headless
	
echo "Install AMP"
sudo yum -y install cloudsoft-amp-karaf-noarch.rpm

echo "Configure MOTD"
sudo cp /vagrant/files/motd /etc/motd

echo "Waiting for AMP to start..."
while ! (sudo grep "BundleEvent STARTED - org.apache.brooklyn.karaf-init" /opt/amp/log/amp.debug.log) > /dev/null ; do
  sleep 2
  echo ".... waiting for AMP to start at `date`"
done

# Restart AMP, so that brooklyn.properties takes effect
# (or could extract default username:password and use REST api)
echo "Restarting AMP..."
sudo systemctl restart amp
