#! /bin/bash
OIFS=$IFS

TREE_DIR="tree"
echo 'Getting packages list...'


echo 'Getting dependencies. This will take a while...'

if [ -d "$TREE_DIR" ]; then
     rm -r $TREE_DIR
fi
mkdir $TREE_DIR
mkfifo equery_fifo

file="equery_fifo"
equery -q list '*' > $file &

while IFS='/'  read -r OVERLAY PACKAGE
do
     if [ ! -d "$TREE_DIR/$OVERLAY" ]; then
       mkdir $TREE_DIR/$OVERLAY
       echo "Working on "$OVERLAY
     fi
     
	 equery -q depends "$PACKAGE" > $TREE_DIR/$OVERLAY/$PACKAGE.txt
done <"$file"

rm equery_fifo

IFS=$OIFS
