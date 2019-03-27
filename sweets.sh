#!/bin/bash
# Demonstrates how case statements can be used with strings too

read -p 'Do you like sweets? (yes/no) ' SWEETS
case $SWEETS in
    yes)
        echo Whoa there, sugar is a killer
        ;;
    no)
        echo Your teeth will outlive you
        ;;
    *)
        echo Please say yes or no
        ;;
esac


