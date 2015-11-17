#!/bin/bash

MATLAB_HOME=$1
MATLAB=$MATLAB_HOME/bin/matlab
MEX=$MATLAB_HOME/bin/mex
IMAGES_DIR=$2

mkdir out

echo "running experiment"
cd src
$MATLAB -nodisplay -r "gpb_experiment('../$IMAGES_DIR')"
cd ..