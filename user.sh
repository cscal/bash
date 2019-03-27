#!/bin/bash

# A user-friendly script for creating users with the most commonly used options
# This asks for the password which is poor for security; it's just for demo

read -p 'Enter username: ' NAME
read -p 'Enter user id: ' UIDD
read -p 'Enter the password: ' PASS
read -p 'Primary group: ' PRIME
read -p 'Secondary groups: ' SEC

useradd -u $UIDD -g $PRIME -G $SEC -p `openssl passwd $PASS` $NAME

tail -1 /etc/passwd
