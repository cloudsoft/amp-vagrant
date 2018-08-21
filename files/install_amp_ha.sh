#!/usr/bin/env bash

echo "Configuring AMP for HA"
sudo cat /vagrant/aws-cred.properties >> /etc/amp/brooklyn.cfg
sudo cat /vagrant/ha.properties >> /etc/amp/org.apache.brooklyn.osgilauncher.cfg
sudo service amp restart

