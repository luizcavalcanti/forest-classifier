#!/bin/bash

if [ $# -lt 2 ]; then
    echo "No arguments. Please provide path to MATLAB home directory and images directory"
    exit 1
fi

MATLAB_HOME=$1
MATLAB=$MATLAB_HOME/bin/matlab
MEX=$MATLAB_HOME/bin/mex
IMAGES_DIR=$2

rm -Rf out
mkdir out

echo "compiling mex"
$MEX srm_boundarygradient.c
$MEX srm_boundarylen.c

echo "running experiment"
$MATLAB -nodisplay -r "srm_experiment('$IMAGES_DIR')"