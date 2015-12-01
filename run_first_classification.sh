#!/bin/bash

TEMP_PATH=tmp
ORIGINAL_IMAGES=database/ptv-mao
SEGMENTED_IMAGES=segmentation/srm/out/
ARFF_PATH=first.arff

# Uncomment if need to run segmentation all over again
# ./srm.sh "$MATLAB_HOME" "../../$IMAGES_DIR"

# Uncomment if need to generate samples for labeling
# rm -rf "$TEMP_PATH"
# mkdir "$TEMP_PATH"
# python first-classification/generate_samples.py "$ORIGINAL_IMAGES" "$SEGMENTED_IMAGES" "$TEMP_PATH"

# Uncomment if need to generate initial arff file
python first-classification/generate_arff_database.py "$TEMP_PATH" "$ARFF_PATH"

python first-classification/label_samples.py "$ORIGINAL_IMAGES" "$TEMP_PATH" "$ARFF_PATH"