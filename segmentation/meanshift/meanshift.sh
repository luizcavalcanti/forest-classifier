#!/bin/bash

DIR_OUTPUT=out
DIR_IMAGES=$DIR_OUTPUT/images
DIR_SEGMENTS=$DIR_OUTPUT/segment
DIR_ORIGINAL_IMAGES=../../data/validation
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
        convert $file $DIR_IMAGES/$filename.ppm
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
echo "done"

# converting files back
echo
echo "Converting ppm files to jpeg..."
for file in $DIR_SEGMENTS/*.pnm
do
    if [[ -f $file ]]; then
	filename=`basename $file`
	filename="${filename%.*}"
	convert $file $DIR_SEGMENTS/$filename
    fi
done
rm $DIR_SEGMENTS/*.pnm
echo "done."
