#!/bin/bash

###################################
## run one-class classifications ##
###################################
WEKA_LIBS=".:manual-classification/lib/*"
ORIGINAL_ARFF_PATH=segments.arff
ARFF_PATH=segments-uniclass.arff
RESULTS_DIR=results/uniclass/
FILTERED_ARFF=filtered_$ARFF_PATH
CFS_ARFF=cfs_$ARFF_PATH

ARFF_OPTIONS="-t $FILTERED_ARFF"
ARFF_OPTIONS_CFS="-t $CFS_ARFF"

echo "deleting previous results"
rm -rf $RESULTS_DIR 2> /dev/null
mkdir $RESULTS_DIR
rm $ARFF_PATH 2> /dev/null

echo "converting muticlass database to uniclass"
python uniclass/convert_multi_to_uniclass.py $ORIGINAL_ARFF_PATH $ARFF_PATH
