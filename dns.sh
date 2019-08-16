#!/bin/bash

# This script populates forward and reverse lookup zones for a DNS server
# It assumes that the zone files have already been created and DNS configured,
# so this script is useful for adding new servers to existing DNS records.
# Create a loop that keeps asking for new server names until a stop condition is reached

shopt -s -o nounset

declare -x IP
declare -x HOST
declare -x FOR
declare -x REV
declare -x SUBNET
declare -x DOM

read -p "Enter the absolute path of your forward lookup file: " FOR
read -p "Enter the absolute path of your reverse lookup file: " REV
read -p "Enter the first 3 octets common to the IP addresses you're entering, e.g. 192.168.1: " SUBNET
read -p "Enter the full domain name exclusive of the hostname: " DOM
printf "%s\n" "Enter the hostname of the server or type quit"
while true ; do
    read -p "Hostname (or quit): " HOST
    if [[ ${HOST} = "quit" ]] ; then
        break
    else
        read -p "Last octet of address for $HOST: " IP
        echo "${HOST}    IN    A   ${SUBNET}.${IP}" >> ${FOR}
        echo "${IP}    IN    PTR    ${HOST}.${DOM}." >> ${REV}
    fi
done

exit 0

