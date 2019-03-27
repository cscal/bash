#!/bin/bash
# Demonstrates case statements

read -p 'The Earth is bigger than Mars. Enter 0 for false or 1 for true. ' PLANET

case $PLANET in
    0)
        echo Go back to school
        ;;
    1)
        echo You get a gold star!
        ;;
    *)
        echo Follow the instructions
        ;;
esac
