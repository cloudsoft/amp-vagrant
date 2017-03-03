#!/bin/bash

# Exit script on error
set -e
echo "================================================================================"
echo "==                            AMP INSTALL :: START                            =="
echo "================================================================================"
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

echo "Configure AMP Properties"
sudo cp /vagrant/files/brooklyn.properties /etc/amp/brooklyn.cfg
sudo chown amp:amp /etc/amp/brooklyn.cfg
sudo chmod 600 /etc/amp/brooklyn.cfg

echo "Add Hyperledger Fabric to AMP Catalog"
sudo curl -o /opt/amp/deploy/hyperledger-0.10-SNAPSHOT.jar -s -S https://s3.amazonaws.com/brooklyn-hyperledger-release/hyperledger-0.10-SNAPSHOT.jar
pattern="items:"
append="- classpath://io.brooklyn.hyperledger:hyperledger/catalog.bom"
sudo sed -i "/${pattern}/a \  ${append}" /opt/amp/catalog/catalog.bom

echo "Configure MOTD"
sudo cp /vagrant/files/motd /etc/motd

echo "Starting AMP..."
sudo systemctl start amp

echo "Waiting for AMP to start..."
sleep 10

while ! (sudo grep "BundleEvent STARTED - org.apache.brooklyn.karaf-init" /var/log/amp/amp.debug.log) > /dev/null ; do
  sleep 10
  echo ".... waiting for AMP to start at `date`"
done

echo "================================================================================================="
echo "==                           ▄▄▄▄▄▄▄▄▄▄▄  ▄▄       ▄▄  ▄▄▄▄▄▄▄▄▄▄▄                             =="
echo "==                          ▐░░░░░░░░░░░▌▐░░▌     ▐░░▌▐░░░░░░░░░░░▌                            =="
echo "==                          ▐░█▀▀▀▀▀▀▀█░▌▐░▌░▌   ▐░▐░▌▐░█▀▀▀▀▀▀▀█░▌                            =="
echo "==                          ▐░▌       ▐░▌▐░▌▐░▌ ▐░▌▐░▌▐░▌       ▐░▌                            =="
echo "==                          ▐░█▄▄▄▄▄▄▄█░▌▐░▌ ▐░▐░▌ ▐░▌▐░█▄▄▄▄▄▄▄█░▌                            =="
echo "==                          ▐░░░░░░░░░░░▌▐░▌  ▐░▌  ▐░▌▐░░░░░░░░░░░▌                            =="
echo "==                          ▐░█▀▀▀▀▀▀▀█░▌▐░▌   ▀   ▐░▌▐░█▀▀▀▀▀▀▀▀▀                             =="
echo "==                          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌                                      =="
echo "==                          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌                                      =="
echo "==                          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌                                      =="
echo "==                           ▀         ▀  ▀         ▀  ▀                                       =="
echo "==                                                                                             =="
echo "==  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄   =="
echo "== ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░▌  =="
echo "== ▐░█▀▀▀▀▀▀▀▀▀  ▀▀▀▀█░█▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌ ▀▀▀▀█░█▀▀▀▀ ▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌ =="
echo "== ▐░▌               ▐░▌     ▐░▌       ▐░▌▐░▌       ▐░▌     ▐░▌     ▐░▌          ▐░▌       ▐░▌ =="
echo "== ▐░█▄▄▄▄▄▄▄▄▄      ▐░▌     ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌     ▐░▌     ▐░█▄▄▄▄▄▄▄▄▄ ▐░▌       ▐░▌ =="
echo "== ▐░░░░░░░░░░░▌     ▐░▌     ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌     ▐░▌     ▐░░░░░░░░░░░▌▐░▌       ▐░▌ =="
echo "==  ▀▀▀▀▀▀▀▀▀█░▌     ▐░▌     ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀█░█▀▀      ▐░▌     ▐░█▀▀▀▀▀▀▀▀▀ ▐░▌       ▐░▌ =="
echo "==           ▐░▌     ▐░▌     ▐░▌       ▐░▌▐░▌     ▐░▌       ▐░▌     ▐░▌          ▐░▌       ▐░▌ =="
echo "==  ▄▄▄▄▄▄▄▄▄█░▌     ▐░▌     ▐░▌       ▐░▌▐░▌      ▐░▌      ▐░▌     ▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌ =="
echo "== ▐░░░░░░░░░░░▌     ▐░▌     ▐░▌       ▐░▌▐░▌       ▐░▌     ▐░▌     ▐░░░░░░░░░░░▌▐░░░░░░░░░░▌  =="
echo "==  ▀▀▀▀▀▀▀▀▀▀▀       ▀       ▀         ▀  ▀         ▀       ▀       ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀   =="
echo "================================================================================================="