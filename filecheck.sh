#!/bin/bash

# This for loop uses a special variable that accepts unlimited arguments
for FILE in $@
do
if [ -f $FILE ]
then
    echo $FILE 'is a regular file.'
elif [ -d $FILE ]
then
    echo $FILE 'is a directory.'
else
    echo $FILE 'is not a regular file or directory.'
fi

ls -l $FILE
done
