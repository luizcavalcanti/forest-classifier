#!/bin/bash

DIR_OUTPUT=out
DIR_ORIGINAL_IMAGES=$1

if [[ ! -f "segdist" ]]; then
    cd src/jpeg
    ./configure
    make
    rm *.o
    mv *.a ..
    cd ..
    make
    cp segdist ..
    rm segdist
    rm *.a
    rm *.o
    cd ..
fi

# recreating output 
rm -Rf $DIR_OUTPUT
mkdir $DIR_OUTPUT

for file in $DIR_ORIGINAL_IMAGES/*.dat
do
    if [[ -f $file ]]; then
        filename=`basename $file`
        filename="${filename%.*}"
        ./segdist -i "${file%.*}".jpg -t 6 -o $DIR_OUTPUT/$filename.jpg 0 -t 6
    fi
done