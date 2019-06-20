#!/bin/bash

# Ensure swap is disabled
#swapoff -a
# use sed regular expressions to find the swap line of /etc/fstab and comment it out
sed -i 's/*swap*/#*swap*/g' /home/student/testfstab

# Disable SELinux
#setenforce 0
#sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# Set bridge in conf
#cat > /etc/sysctl.d/k8s.conf << EOF
#net.bridge.bridge-nf-call-ip6tables = 1
#net.bridge.bridge-nf-call-iptables = 1
#EOF

# Add firewall rules to master
#firewall-cmd --permanent --add-port=6443/tcp
#firewall-cmd --permanent --add-port=2379-2380/tcp
#firewall-cmd --permanent --add-port=10250/tcp
#firewall-cmd --permanent --add-port=10251/tcp
#firewall-cmd --permanent --add-port=10252/tcp
#firewall-cmd --permanent --add-port=10255/tcp
#firewall-cmd --reload
