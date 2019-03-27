#!/bin/bash

read -p 'Enter username: ' NAME

read -p 'Enter user id: ' UIDD
read -p 'Enter the password: ' PASS

read -p 'Primary group: ' PRIME

read -p 'Secondary groups: ' SEC

useradd -u $UIDD -g $PRIME -G $SEC -p `openssl passwd $PASS` $NAME

tail -1 /etc/passwd
