#!/bin/bash
# This demonstrates infinite loops, disguised as fake backups.

while true
do
    FILE=$(touch backup-$(date +%s).bkup)
    echo $FILE was created
    sleep 4
done

