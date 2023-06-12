# haproxy-labs
A simple project to create an architecture with High Availability.

---

## Requirements

- [VirtualBox v7](https://www.virtualbox.org/wiki/Downloads) *(**not recommended** for M1/M2 users)*
- [VMware Fusion Player v13](https://customerconnect.vmware.com/en/evalcenter?p=fusion-player-personal-13) *(**recommended** for M1/M2 users)*
- [Vagrant v2.3.6](https://developer.hashicorp.com/vagrant/downloads?product_intent=vagrant)
- [Wireshark](https://www.wireshark.org/download.html)


## Getting Started

### How to setup the Virtual Machines

1. First of all, choose your favorite provider according to the recommendation above.
1. If the choice was VirtualBox, you need to make sure that you have a **private network** on VirtualBox. For that, just do:
   1. Open the VirtualBox and go to: **File > Tools > Network Manager > Host-only Networks**
1. However, here we will be using **VMWare Fusion Player**. For that, just do:
   ```shell
   make setup
   make up
   ```

   StdOut:
   ```shell
   ...
   ==> ubuntu-nginx-3: Running provisioner: shell...
       ubuntu-nginx-3: Running: inline script
       ubuntu-nginx-3: INSTALLER: Installation complete and ready to use!
   ```

1. Test the connection to verify that everything is OK:
   ```shell
   make test
   ```

   StdOut:
   ```shell
   > make test
   ansible all -m ping -o
   172.16.47.101 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3"},"changed": false,"ping": "pong"}
   172.16.47.103 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3"},"changed": false,"ping": "pong"}
   172.16.47.102 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3"},"changed": false,"ping": "pong"}
   ```