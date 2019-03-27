#!/bin/bash

i=0
for file in *.txt
do
    ((i++))
done
echo 'There are '$i 'txt files.'
