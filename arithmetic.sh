#!/bin/bash
# Demonstrating how to use arithmetic in bash

read -p 'Enter a number: ' NUM1
read -p 'Enter another number: ' NUM2

let SUM=$NUM1+$NUM2
let PROD=$NUM1*$NUM2

echo 'The sum is ' $SUM
echo 'The product is ' $PROD
