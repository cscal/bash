#!/bin/bash

# Set vars for IP and pod network CIDR
MASTERIP=`hostname -I | cut --delimiter=' ' -f1`
read -p "Enter network CIDR: " CIDR          # old example: 10.244.0.0/16

# Ensure swap is disabled
swapoff -a
# use sed to find the swap line of /etc/fstab and comment it out
sed -i '/swap/ s/^/#/' /etc/fstab

# Disable SELinux
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# Set bridge in conf
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# Add firewall rules to master
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --reload

# Configure the kubernetes repo
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg  https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Make all changes
sysctl --system

# Install Docker and Kubernetes
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
export VERSION=18.06 && curl -sSL get.docker.com | sh
yum install -y kubeadm kubelet kubectl
systemctl start docker && systemctl enable docker
systemctl start kubelet && systemctl enable kubelet

# Initialize kube and save token information.
mkdir -p $HOME/.kube
kubeadm init --apiserver-advertise-address=$MASTERIP --pod-network-cidr=$CIDR >> $HOME/.kube/token

# Do what kubeadm said to do.
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# Apply flannel yaml
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Done
echo 'Script finished. Now run the worker script on the kubernetes workers.'
echo 'Token information saved at /root/.kube/token'
