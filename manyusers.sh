#!/bin/bash

# Create 100 users

for i in `seq 1 100`
do
    username=user${i}
    useradd ${username}
done
