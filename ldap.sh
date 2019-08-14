#!/bin/bash

# This script installs and configures an LDAP server
read -p 'Enter domain: ' DOM
read -p 'Enter top level domain: ' TOP

# Disable SELinux
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# Install ldap
yum install -y openldap openldap-clients openldap-servers openssl
systemctl start slapd && systemctl enable slapd

# Configure domain and admin
cat << EOF > hdb.ldif
dn: olcDatabase={2}hdb,cn=config
changeType: modify
replace: olcSuffix
olcSuffix: dc=$DOM,dc=$TOP
-
replace: olcRootDN
olcRootDN: cn=admin,dc=$DOM,dc=$TOP
-
add: olcRootPW
olcRootPW: password
EOF
ldapmodify -Y EXTERNAL -H ldapi:/// -f hdb.ldif

# Configure monitor
cat << EOF > monitor.ldif
dn: olcDatabase={1}monitor,cn=config
changeType: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read by dn.base="cn=admin,dc=$DOM,dc=$TOP" read by * none
EOF
ldapmodify -Y EXTERNAL -H ldapi:/// -f monitor.ldif

# Create base structure
cat << EOF > base.ldif
dn: dc=$DOM,dc=$TOP
objectClass: dcObject
objectClass: organization
o: $DOM.$TOP
dc: $DOM

dn: ou=users,dc=$DOM,dc=$TOP
objectClass: organizationalUnit
objectClass: top
ou: users

dn: ou=groups,dc=$DOM,dc=$TOP
objectClass: organizationalUnit
objectClass: top
ou: groups
EOF
ldapadd -x -D "cn=admin,dc=$DOM,dc=$TOP" -f base.ldif -w password

# Add these things because always
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif -w password
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif -w password
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif -w password

# Verify this worked
echo "Look at this output and make sure it looks correct"
ldapsearch -x -b "dc=$DOM,dc=$TOP"
ldapsearch -x -w password -D "cn=admin,dc=$DOM,dc=$TOP" -b "dc=$DOM,dc=$TOP" "(objectclass=*)"

# Install phpmyadmin
yum install -y epel-release
yum install -y phpldapadmin httpd

# Configure phpldapadmin
sed -i "305s/array(''));/array('dc=$DOM,dc=$TOP'));/" /etc/phpldapadmin/config.php
sed -i "332s/cn=Manager,dc=example,dc=com/cn=admin,dc=$DOM,dc=$TOP/" /etc/phpldapadmin/config.php
sed -i '398s/uid/dn/' /etc/phpldapadmin/config.php
sed -i '/Require local/a\
     Require all granted' /etc/httpd/conf.d/phpldapadmin.conf

# Set services
systemctl stop firewalld && systemctl disable firewalld
systemctl start httpd && systemctl enable httpd
