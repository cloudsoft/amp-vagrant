#!/bin/bash

# Exit script on error
set -e

# Set Java Vars
JAVA_VERSION=8
export JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64/

echo "Ensure credentials provided"
if [ -z "$AMP_DOWNLOAD_USER" ] || [ -z "$AMP_DOWNLOAD_PASS" ]; then
  cat >&2 <<EOL
ERROR - AMP Install Script failed to execute: - Username and/or Password not set
ERROR - 
ERROR - Please reattempt the provisioning step supplying credentials:
ERROR -    user=myuser password=mypassword vagrant provision amp
ERROR - 
ERROR - Or, alternatively, destroy the existing AMP instance:
ERROR -    vagrant destroy amp
ERROR - And rerun vagrant up supplying credentials:
ERROR -    user=myuser password=mypassword vagrant up amp
EOL
  exit 1
fi

echo "Download AMP"
curl -o cloudsoft-amp-karaf.tar.gz -s -S -u "${AMP_DOWNLOAD_USER}:${AMP_DOWNLOAD_PASS}" http://developers-origin.cloudsoftcorp.com/amp/latest/cloudsoft-amp-karaf-latest.tar.gz

echo "Validate downloaded file is an archive"
download_type=`file cloudsoft-amp-karaf.tar.gz`

if ! (echo $download_type | grep 'gzip compressed data') > /dev/null ; then
  cat >&2 <<EOL
ERROR - Downloaded AMP archive is not valid tar.gz archive
ERROR - type: ${download_type}
ERROR -
EOL

  if grep -i unauthorized cloudsoft-amp-karaf.tar.gz > /dev/null; then
    cat >&2 <<EOL
ERROR - The AMP download was unauthorized please check your credentials
ERROR - and reattempt the provisioning step:
ERROR -    user=myuser password=mypassword vagrant provision amp
EOL
  elif grep -i "not found" cloudsoft-amp-karaf.tar.gz > /dev/null; then
    cat >&2 <<EOL
ERROR - The AMP download URL was invalid, please check the AMP version
ERROR - configured in servers.yaml and run the provision step again
ERROR - if the version was incorrect:
ERROR -    user=myuser password=mypassword vagrant provision amp
ERROR - If you are unsure what version to expect or continue to see
ERROR - problems please reach out to Cloudsoft support who will
ERROR - assist you further.
EOL
  fi
  exit 1
fi

echo "Restarting Syslog"
sudo systemctl restart rsyslog

echo "Install Java"
sudo sh -c "export DEBIAN_FRONTEND=noninteractive; apt-get install --yes openjdk-${JAVA_VERSION}-jre-headless"
sudo sed -i '/assistive_technologies/ s/^#*/#/' /etc/java-8-openjdk/accessibility.properties

echo "Install AMP"
tar zxf cloudsoft-amp-karaf.tar.gz
mv cloudsoft-amp-karaf-${AMP_VERSION} cloudsoft-amp-karaf

echo "Configure AMP Properties"
mkdir -p /home/vagrant/.brooklyn
cp /vagrant/files/brooklyn.properties /home/vagrant/.brooklyn/
chmod 600 /home/vagrant/.brooklyn/brooklyn.properties

echo "Configure MOTD"
sudo cp /vagrant/files/motd /etc/motd

echo "Installing Karaf wrapper service"
cd /home/vagrant/cloudsoft-amp-karaf
echo ".. starting karaf manually"
./bin/start
echo ".. wait for karaf to start"
while ! ./bin/client version > /dev/null 2>&1; do
  echo ".... waiting for 5 seconds"
  sleep 5
done
echo ".. installing service-wrapper feature"
./bin/client "feature:install service-wrapper" > /dev/null 2>&1
echo ".. creating AMP service wrapper"
./bin/client "wrapper:install --name amp" > /dev/null 2>&1
echo ".. stopping karaf manually"
./bin/stop
echo ".. wait for karaf to stop"
while ./bin/client version > /dev/null 2>&1; do
  echo ".... waiting for 5 seconds"
  sleep 5
done

echo "Configure AMP persistence"
grep -q -e "^persistMode"  ./etc/org.apache.brooklyn.osgilauncher.cfg || echo "persistMode=AUTO" >> ./etc/org.apache.brooklyn.osgilauncher.cfg
grep -q -e "^persistenceDir"  ./etc/org.apache.brooklyn.osgilauncher.cfg || echo "persistenceDir=/vagrant/amp-persistence" >> ./etc/org.apache.brooklyn.osgilauncher.cfg

echo "Configure amp service to run as non-root user"
grep -q -F "User=vagrant" ./bin/amp.service || sed -i '/ExecStop=.*/a User=vagrant' ./bin/amp.service 
grep -q -F "Group=vagrant" ./bin/amp.service || sed -i '/User=.*/a Group=vagrant' ./bin/amp.service 

echo "Configure wrapper to restart on failure"
grep -q -F "Restart=always" ./bin/amp.service || sed -i '/ExecStop=.*/a Restart=always' ./bin/amp.service 
grep -q -F "RestartSec=3" ./bin/amp.service || sed -i '/ExecStop=.*/a RestartSec=3' ./bin/amp.service 

echo "Adding amp service to systemd"
sudo systemctl enable /home/vagrant/cloudsoft-amp-karaf/bin/amp.service
echo "Starting amp"
sudo systemctl start amp
