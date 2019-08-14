#!/bin/bash

# This sets up the LDAP server to serve the home directories over NFS

# Install
yum install -y nfs-utils nfs-utils-lib

# Services
systemctl enable rpcbind    &&  systemctl start rpcbind
systemctl enable nfs-server &&  systemctl start nfs-server
systemctl enable nfs-lock   &&  systemctl start nfs-lock
systemctl enable nfs-idmap  &&  systemctl start nfs-idmap

# Make home dir
mkdir /home/users

# Create exports
cat << EOF > /etc/exports
/home/users    192.168.0.0/24(rw,sync)
EOF

exportfs -av

systemctl restart nfs-server
