/*
 * script for copying files
 */

filename: organise_photos.sh
#!/bin/bash
file="$1"
printf "filename: %s\n" "$file"
#
stripDoubleQuotes () {
    var="$@"
    # https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    echo "$var" | sed "s/\"//g"
}
while IFS="," read -r Geom_ID Ward
do
    #printf "GeometryID: %s; Ward: %s\n" "$Geom_ID" "$Ward"
    #printf "GeometryID: %s; Ward: %s\n" "$(stripDoubleQuotes) $Geom_ID" $(stripDoubleQuotes) "$Ward"
    #
    geom_id="$(stripDoubleQuotes $Geom_ID)"
    output_directory="$(pwd)"/"$(stripDoubleQuotes $Ward)"
    #printf "file_name: %s folder: %s\n" "$geom_id" "$output_directory"
    mkdir -p -v "$output_directory"
    #
    find /home/QGIS/projects/Havering/Mapping -name "*$geom_id*.png" -exec cp -v {} "$output_directory" \;
done < "$file"


Useage: $ sh organise_photos.sh <file_with_photo_list e.g., junction_list.csv>