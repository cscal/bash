#!/bin/bash
# Demonstrates the while loop, incrementing, and comparison

i=1
while [ $i -lt 11 ] ;
do
    echo 'counting, now at' $i
    ((i++))
    sleep 1
done
