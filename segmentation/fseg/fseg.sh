#!/bin/bash

MATLAB_HOME=$1
MATLAB=$MATLAB_HOME/bin/matlab
MEX=$MATLAB_HOME/bin/mex
IMAGES_DIR=$2

rm -Rf out
mkdir out

echo "compiling mex"
cd src
$MEX SHcomp.c
$MEX SHcomp_givenRange.c
$MEX SHedge_1s.c
$MEX RmSmRg.c
$MEX AdjMxCrt.c

echo "running experiment"
$MATLAB -nodisplay -r "fseg_experiment('../$IMAGES_DIR')"
cd ..