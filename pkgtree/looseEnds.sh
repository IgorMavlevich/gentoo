#! /bin/bash
OIFS=$IFS

TREE_DIR="tree"
NONBREAKING=0

if [ -f "looseEnds.list" ]; then
    rm looseEnds.list
fi

if [ -f "Overlays" ]; then
     rm -r Overlays
fi

if [ -f "Packages" ]; then
     rm -r Packages
fi

mkfifo Overlays
mkfifo Packages
echo "List of (kinda) safely removable packages: " >> looseEnds.list

ls "$TREE_DIR" > Overlays &

while read -r OVERLAY
do
    ls -s "$TREE_DIR/$OVERLAY" > Packages &
    while IFS=' ' read -r SIZE PACKAGE
    do
        if [ $SIZE == '0' ]; then
            echo "$OVERLAY/${PACKAGE%.txt}" >> looseEnds.list
            echo "$OVERLAY/${PACKAGE%.txt}"
            let NONBREAKING+=1
        fi
    done < Packages
done < Overlays

echo "There are $NONBREAKING removable packages in the system"

rm Overlays
rm Packages

IFS=$OIFS
