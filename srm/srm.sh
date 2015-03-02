#!/bin/bash

MATLAB_HOME=~/MATLAB/R2013b/
MATLAB=$MATLAB_HOME/bin/matlab
MEX=$MATLAB_HOME/bin/mex

rm -Rf output
mkdir output

echo "compiling mex"
$MEX srm_boundarygradient.c
$MEX srm_boundarylen.c

echo "running demo"
$MATLAB -nodisplay -r "srm_experiment('../data/validation/')"

