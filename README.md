# amp-vagrant
Vagrant files to bootstrap an AMP environment consisting of an AMP instance and multiple byon nodes based on Ubuntu.

The Vagrant environment has been verified on OSX 10.11 and Windows 10 using Vagrant 1.8.0+ and VirtualBox 5.0.10+. It is recommended to use the latest version of both Vagrant and Virtualbox.

![Vagrant 1.8.4+](https://img.shields.io/badge/Vagrant-1.8.0%2B-blue.svg) ![Virtualbox 5.0.10+](https://img.shields.io/badge/VirtualBox-5.0.10%2B-blue.svg) ![OSX 10.11](https://img.shields.io/badge/OSX-10.11-blue.svg) ![Windows 10](https://img.shields.io/badge/Windows-10-blue.svg)

## How to use

For instructions on using this Vagrant environment with Cloudsoft AMP please refer to the [Get AMP Running](http://docs.cloudsoft.io/tutorials/tutorial-get-amp-running.html) tutorial.

### Customising VMs 
The following optional steps are provided to describe how you may override the default VM configurations.

#### Running OS Updates
As a convenience you can set `run_os_update` to `true` in the `servers.yaml` file to automatically run package updates for `apt` and `rpm` based distros. This defaults to `false` to minimise the amount of data downloaded.

#### IP Addresses
All nodes will start with a private interface on the 10.10.10.0/24 network. The default IPs assigned to each node are as follows:

| vagrant host | ip address   |
| ------------ | ------------ |
| amp          | 10.10.10.100 |
| byon1        | 10.10.10.101 |
| byon2        | 10.10.10.102 |
| byon3        | 10.10.10.103 |
| byon4        | 10.10.10.104 |

You can override the IP addresses assigned to each node by changing the `ip` for each machine in `servers.yaml`

**NOTE** These private addresses will only be accessible from your local machine. It is possible, but not documented, to expose some service ports via your local machine (reach out if you believe this would be useful for you).

#### VM Resources
You can alter the base OS, number of CPUs and amount of RAM allocated to each VM by altering the `box`, `cpu` or `ram` fields in `servers.yaml`. For example to switch a VM to Ubuntu Trust64 with 3 cpu cores and 1GB of RAM you would change the fields as follows:

```
box: ubuntu/trusty64
ram: 1024
cpus: 3
```

## License

amp-vagrant is built on [Cloudsoft AMP](http://www.cloudsoftcorp.com) and [Apache Brooklyn](http://brooklyn.io)
and is copyright &copy; 2016 by Cloudsoft Corporation.

This software is released under the terms of [the Cloudsoft EULA](LICENSE.txt).
