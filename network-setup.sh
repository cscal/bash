#!/bin/bash

# This script automatically configures networking.
# A future feature is doing this for all servers on the subnet.

# I think the best way to automate network config for large
# numbers of non-cloud servers is to create a PXE kickstart file.
# However kickstart only understands variables in Pre- and Post-
# installation scripts, or in scripts run in Post- mounted on NFS.
# Every time the script runs it needs to increment an IP variable
# and save that variable to a persistent text file.
# Loops won't work because the script is run anew on each system.

# So the below is just an example of using sed to set static IP

sed -i[backup] {
s/BOOTPROTO=dhcp/BOOTPROTO=static
s/ONBOOT=no/ONBOOT=yes
s/NM_CONTROLLED=yes/NM_CONTROLLED=no
IPADDR=192.168.1.3
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS=8.8.8.8
n
} /etc/sysconfig/network-scripts/ifcfg-enp0s3
