#!/bin/bash

TEMP_PATH=tmp

# Uncomment if need to run segmentation all over again
# ./srm.sh "$MATLAB_HOME" "../../$IMAGES_DIR"

# Uncomment if need to generate samples for labeling
# rm -rf "$TEMP_PATH"
# mkdir "$TEMP_PATH"
# python first-classification/generate_samples.py "database/ptv-mao" "segmentation/srm/out/" "$TEMP_PATH"

# Uncomment if need to generate initial arff file
python first-classification/generate_arff_database.py "$TEMP_PATH" "first.arff"