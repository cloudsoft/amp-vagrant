# amp-pro-vagrant
Vagrant files to bootstrap an AMP Pro environment consisting of an AMP Pro instance and multiple byon nodes based on Ubuntu.

The Vagrant environment has been verified on OSX 10.11 and Windows 10 using Vagrant 1.8.0+ and VirtualBox 5.0.10+. It is recommended to use the latest version of both Vagrant and Virtualbox.

![Vagrant 1.8.0+](https://img.shields.io/badge/Vagrant-1.8.0%2B-blue.svg) ![Virtualbox 5.0.10+](https://img.shields.io/badge/VirtualBox-5.0.10%2B-blue.svg) ![OSX 10.11](https://img.shields.io/badge/OSX-10.11-blue.svg) ![Windows 10](https://img.shields.io/badge/Windows-10-blue.svg)

## How to use

This assumes you have already installed Virtualbox and Vagrant on your local machine and have external network access to the Ubuntu update repositories and the Cloudsoft Artifactory.

The supplied `servers.yaml` defines both an AMP Pro node and 4 small BYON nodes, you can ignore the BYON nodes if you only intend to demonstrate using cloud locations.

AMP Pro is deployed with login authentication disabled and persistance enabled by default (mapped through to the `amp-pro-persistance` directory in your local repo).

### Starting AMP Pro

1. Clone and cd into this repository

    ```
    git clone https://github.com/cloudsoft/amp-pro-vagrant
    cd amp-pro-vagrant
    ```

2. Start the AMP Pro node

    ```
    vagrant up amp-pro
    ```

3. Connect to the [AMP Pro Web Console](http://10.10.10.100:8081/)

### Starting BYON Nodes

1. You can start the BYON nodes with (Note that you can add additional nodes to `servers.yaml` if desired).

    ```
    vagrant up byon1 byon2 byon3 byon4
    ```

2. They will be availble to add to your blueprint, for example to add all 4 nodes to a `byon-all` location.

    ```
    location:
      byon-all:
        user: vagrant
        password: vagrant
        hosts:
          - 10.10.10.101
          - 10.10.10.102
          - 10.10.10.103
          - 10.10.10.104
    ````

### Terminal Access to AMP Pro Node

You may connect using `vagrant ssh <node name>`, for example:

    vagrant ssh amp-pro

Or by ssh'ing to the VM as the `vagrant` user:

    ssh vagrant@10.10.10.100

See the [IP Addresses section](#IP-Addresses).

### Starting/Stopping/Status Checking AMP Pro

AMP Pro is running under the control of SystemD and can be started/stopped as follows (logging in as described above):

    sudo systemctl status amp-pro
    sudo systemctl start amp-pro
    sudo systemctl stop amp-pro

### Customising VMs 
The following optional steps are provided to describe how you may override the default VM configurations.

#### AMP Pro Version
You can either use the supplied AMP Pro version or override by changing the `AMP_PRO_VERSION` field in `servers.yaml`.

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

amp-pro-vagrant is built on [Cloudsoft AMP](http://www.cloudsoftcorp.com) and [Apache Brooklyn](http://brooklyn.io)
and is copyright &copy; 2016 by Cloudsoft Corporation.

This software is released under the terms of [the Cloudsoft EULA](LICENSE.txt).