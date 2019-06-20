#!/bin/bash

# This shows more complex syntax in case statements including |

echo -n 'What animal did you see? '
read ANIMAL

case $ANIMAL in
    'lion' | 'tiger')
        echo 'You better start running'
    ;;
    'chicken' | 'goose' | 'duck')
        echo 'Eggs for breakfast!'
    ;;
    'babelfish')
        echo 'Did it fall out your ear?'
    ;;
    *)
        echo 'I never heard of that'
esac
