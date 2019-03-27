#!/bin/bash

# This script accepts a command line argument for a directory to search
# for text files, then counts the number of text files.

# If there aren't any text files, don't enter the loop. Corrects i value.
ls $1/*.txt &> /dev/null
if [ $? -ne 0 ]
then
    echo 'There are 0 files ending in .txt. If you were expecting output,
        ensure that you typed the directory name correctly as the argument.'
else
    i=0
    for file in $1/*.txt
    do
        ((i++))
    done
    echo 'There are '$i 'files ending in .txt'
fi
