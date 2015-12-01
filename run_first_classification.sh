#!/bin/bash

TEMP_PATH=tmp

# Uncomment if need to run segmentation all over again
# ./srm.sh "$MATLAB_HOME" "../../$IMAGES_DIR"

# Uncommend if need to generate samples for labeling
# python first-classification/generate_samples.py "database/ptv-mao" "segmentation/srm/out/" "$TEMP_PATH"

python first-classification/generate_arff_database.py "$TEMP_PATH" "first.arff"