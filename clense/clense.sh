#! /bin/bash

TMPDIR="/tmp/clense"

if [ -f world.list ]; then
    rm world.list
fi

if [ -f clense.log ]; then
    rm clense.log
fi

if [ -f deselect ]; then
    rm deselect
fi

mkdir "$TMPDIR"
cp /var/lib/portage/world world.list

TOTAL=$(wc -l < world.list)
COUNT=1

while read -r PACKAGE ; do
    PKG=$(echo "$PACKAGE" | cut -d '/' -f 2)
    echo -ne "Processing package $COUNT/$TOTAL \r"
    equery depends "$PACKAGE" >> "$TMPDIR/$PKG"
    ((COUNT++))
done < world.list

echo "These packages can be removed (maybe):"
ls "$TMPDIR" | grep -v 0

echo "Be careful!"
