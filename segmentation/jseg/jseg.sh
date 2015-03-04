#!/bin/bash

DIR_OUTPUT=out
DIR_ORIGINAL_IMAGES=../../data/validation

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

# recreating output 
rm -Rf $DIR_OUTPUT
mkdir $DIR_OUTPUT

for file in $DIR_ORIGINAL_IMAGES/*.jpg
do
    if [[ -f $file ]]; then
    filename=`basename $file`
    ./segdist -i $file -t 6 -o $DIR_OUTPUT/$filename 0.4 -t 6
    fi
done