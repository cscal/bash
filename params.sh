#!/bin/bash
# Use this script with arguments to demonstrate how arguments
# are used in bash

echo The first argument is $1
echo The second argument is $2
echo The third argument is $3

echo \$ $$  PID of the script
echo \# $#  count arguments
echo \? $?  last return code
echo \* $*  all the arguments
echo $0 is the name of the script
