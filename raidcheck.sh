#!/bin/bash

# This script checks the RAID array for errors. If any are found, create a log.

sudo mdadm --action=check /dev/md127

# Now the script needs to wait until the check finishes.
sleep 28800


if [ `cat /sys/block/md127/md/mismatch_cnt` -ne 0 ]
then
    echo "RAID errors were found, but because this is RAID1, there may be \
        false positives. Investigate." > ~/RAIDERROR
fi
