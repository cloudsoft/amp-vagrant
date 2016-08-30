# -*- mode: ruby -*-
# # vi: set ft=ruby :

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.8.1"
VAGRANTFILE_API_VERSION = "2"

# Autocorrect Port Clashes
DEFAULT_AUTOCORRECT = false

# Update OS (Debian/RedHat based only)
UPDATE_OS_CMD = "(sudo apt-get update && sudo apt-get -y upgrade) || (sudo yum -y update)"

# Require YAML module
require 'yaml'

# Read YAML file with box details
yaml_cfg = YAML.load_file(__dir__ + '/servers.yaml')

# Create boxes
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Iterate through server entries in YAML file
  yaml_cfg["servers"].each do |server|
    config.vm.define server["name"] do |server_config|
      server_config.vm.box = server["box"]

      server_config.vm.box_check_update = yaml_cfg["default_config"]["check_newer_vagrant_box"]

      if server.has_key?("ip")
        server_config.vm.network "private_network", ip: server["ip"]
      end
      #the port mapping config is in servers.yaml. In the event that auto-correction fails, please edit the port mappings in that file 
      if server.has_key?("forwarded_ports")
        server["forwarded_ports"].each do |port|
          if port.has_key?("autocorrect")
            autocorrect = true
          else
            autocorrect = DEFAULT_AUTOCORRECT
          end
          server_config.vm.network "forwarded_port", guest: port["guest"], host: port["host"], guest_ip: port["guest_ip"], auto_correct: autocorrect
        end
      end

      server_config.vm.hostname = server["name"]
      server_config.vm.provider :virtualbox do |vb|
        vb.name = server["name"]
        vb.memory = server["ram"]
        vb.cpus = server["cpus"]
      end
      
      if yaml_cfg["default_config"]["run_os_update"]
        server_config.vm.provision "shell", privileged: false, inline: UPDATE_OS_CMD
      end
      
      if server["shell"] && server["shell"]["cmd"]
        server["shell"]["cmd"].each do |cmd|
          server_config.vm.provision "shell", privileged: false, inline: cmd
        end
      end

      server_config.vm.post_up_message = server["post_up_message"]
    end
  end
end


# ALTERING PORT FORWARDING
# If you are reading this you have likely been instructed by Vagrant to alter the example
# line below due to the forwarded port colliding with one alread in use on your system.
#
#   config.vm.network :forwarded_port, guest: 80, host: 1234
#
# This Vagrantfile does not define the port mapping here, instead you should alter
# the following line in the `servers.yaml` file in this directory.
#
#   host: 8081
#
# Change 8081 to a port that is not in use on your local machine before attempting
# to run vagrant up again.