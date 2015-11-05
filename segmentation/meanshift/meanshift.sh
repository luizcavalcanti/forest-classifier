#!/bin/bash

DIR_ORIGINAL_IMAGES=$1
DIR_OUTPUT=out
DIR_IMAGES=$DIR_OUTPUT/images
DIR_SEGMENTS=$DIR_OUTPUT/segment
EXECUTABLE=edison


# clean previous build and output
rm $EXECUTABLE
rm -Rf $DIR_OUTPUT
mkdir -p $DIR_IMAGES
mkdir -p $DIR_SEGMENTS

# make new build
make

# give executable permission
chmod +x $EXECUTABLE

# converting files
echo
echo "Converting jpg files to ppm..."
for file in $DIR_ORIGINAL_IMAGES/*.jpg
do
    if [[ -f $file ]]; then
        filename=`basename $file`
        filename="${filename%.*}"
        convert "${file%.*}".jpg $DIR_IMAGES/$filename.ppm
    fi
done
echo "done."

# generating script
echo
echo "Generating EDS script..."
python generate_script.py
echo "done"

# execute experiment
echo
echo "Starting experiment"
./edison out/temp.eds

rm -Rf $DIR_IMAGES
mv $DIR_SEGMENTS/* $DIR_OUTPUT
rm -Rf $DIR_SEGMENTS
echo "done."
