#!/bin/bash
# Demonstrates Until loop

i=10
until [ $i -lt 1 ] ;
do
    echo 'counting down' $i
    ((i--))
    sleep 1
done
