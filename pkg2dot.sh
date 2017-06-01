#! /bin/bash
OIFS=$IFS

file="./equery.txt"

if [ -f "depends.dot" ]; then
    rm depends.dot
fi

echo "digraph depends {" >> depends.dot
echo "scale=32" >> depends.dot #32 is the largest factor before segfault pack=true scale=20 concentrate=true epsilon=.0001 quadtree=true

while IFS='/'  read -r OVERLAY PACKAGE
do
    while IFS='/' read -r DOVERLAY DPACKAGE
    do
        if [ "$PACKAGE" != "" ]; then
            echo "\"$PACKAGE\" -> \"$DPACKAGE\"" >>   depends.dot
        fi
    done < "./packages/$OVERLAY/$PACKAGE.txt"
done <"$file"

echo "}" >> depends.dot

#neato -Tpng depends.dot -O

IFS=$OIFS
