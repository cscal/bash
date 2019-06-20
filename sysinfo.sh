#!/bin/bash

echo 'Welcome to the Server'
echo 'What would you like to know about this server?'

echo 1: Hostname
echo 2: IP address
echo 3: Storage
echo 4: Memory
echo 5: Users
echo 6: OS version
echo 7: Architecture
echo 8: CPU
echo 9: Uptime

read G

case $G in
    1) hostname ;;
    2) hostname -I ;;
    3) df -h | grep root | tr -s " " | cut -d " " -f2 ;;
    4) free -m | grep -i mem | tr -s " " | cut -d " " -f2 ;;
    5) w | head -1 | tr -s " " | cut -d " " -f7 ;;
    6) uname -r ;;
    7) uname -r | cut -d "." -f7 ;;
    8) cat /proc/cpuinfo | grep 'model name' | cut -d ":" -f2 ;;
    9) uptime | cut -d "," -f1 ;;
    *) echo 'Please choose a number: 1-9'

esac
