#!/bin/bash

DIR_OUTPUT=out
DIR_IMAGES=$DIR_OUTPUT/images
DIR_SEGMENTS=$DIR_OUTPUT/segment
DIR_ORIGINAL_IMAGES=$1

#building
cd src
make
mv segment ../mseg
cd ..

# recreating output 
# rm -Rf $DIR_OUTPUT
mkdir -p $DIR_IMAGES
mkdir -p $DIR_SEGMENTS

# converting files (only the ones with metadata)
echo
echo "Converting jpg files to ppm..."
for file in $DIR_ORIGINAL_IMAGES/*.jpg
do
    if [[ -f $file ]]; then
        echo $file
        filename=`basename $file`
        filename="${filename%.*}"
        convert "${file%.*}".jpg $DIR_IMAGES/$filename.ppm
    fi
done
echo "done."

# executing
for file in $DIR_IMAGES/*.ppm
do
    if [[ -f $file ]]; then
    filename=`basename $file`
    ./mseg 0.8 600 400 $file $DIR_SEGMENTS/$filename
    fi
done

# converting files back
echo
echo "Converting ppm files to jpeg..."
for file in $DIR_SEGMENTS/*.ppm
do
    if [[ -f $file ]]; then
    filename=`basename $file`
    filename="${filename%.*}"
    convert $file $DIR_SEGMENTS/$filename.jpg
    fi
done

# clear results
rm $DIR_SEGMENTS/*.jpg
mv $DIR_SEGMENTS/* $DIR_OUTPUT
rm -Rf $DIR_IMAGES
rm -Rf $DIR_SEGMENTS

echo "done."
