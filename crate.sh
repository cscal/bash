#!/bin/bash
# Demonstrating use of functions

read -p 'Please enter filename to create: ' FILENAME

createfile () {
    touch $FILENAME
    echo 'Creating' $FILENAME
}

createfile
echo $FILENAME created
