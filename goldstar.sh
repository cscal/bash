#!/bin/bash
# This demonstrates use of comparison operators in bash

read -p 'Enter a number between 1-100: ' NUM

if [ $NUM -gt 1 -a $NUM -lt 100 ]
then
    echo 'You get a gold star!'
else
    echo 'You did not follow the instructions.'
fi

