#! /bin/bash

while read -r PACKAGE ; do
    emerge -vqpc $PACKAGE >> worldcheck.log
done < world.list
