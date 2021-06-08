#!/bin/bash
file="junction_list.csv"
while IFS=: read -r f1 f2
do
        # display fields using f1, f2,..,f7
        printf 'GeometryID: %s, Ward: %s, Home Dir: %s\n' "$f1" "$f2"
done <"$file"

find . -name \*.jar | xargs cp -t /destination_dir


/home/tim/HVG_Photos/junction_list.csv