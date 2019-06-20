#!/bin/bash

# This script automatically configures networking.
# A future feature is doing this for all servers on the subnet.

#cp /etc/sysconfig/network-scripts/ifcfg-enp0s3 /etc/sysconfig/network-scripts/ifcfg-enp0s3.bak

sed -i[backup] {
s/BOOTPROTO=dhcp/BOOTPROTO=static
s/ONBOOT=no/ONBOOT=yes
s/NM_CONTROLLED=yes/NM_CONTROLLED=no
IPADDR=192.168.
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS=
n
} /etc/sysconfig/network-scripts/ifcfg-enp0s3
