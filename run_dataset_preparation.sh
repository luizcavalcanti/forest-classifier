#!/bin/bash

ORIGINAL_IMAGES=database/ptv-mao
SEGMENTED_IMAGES=segmentation/srm/out/
SAMPLES_PATH=tmp
ARFF_PATH=segments.arff

# Uncomment if need to generate samples for labeling
# rm -rf "$SAMPLES_PATH"
# mkdir "$SAMPLES_PATH"
# python preparation/generate_samples.py "$ORIGINAL_IMAGES" "$SEGMENTED_IMAGES" "$SAMPLES_PATH"

# Uncomment if need to generate initial arff file
# python preparation/generate_arff_file.py "$SAMPLES_PATH" "$ARFF_PATH"

# Uncomment if need to label samples
# python preparation/label_samples.py "$ORIGINAL_IMAGES" "$SAMPLES_PATH" "$ARFF_PATH"

# Uncomment if need to update arff attributes (it spares id and class only)
# python preparation/generate_arff_attributes.py "$SAMPLES_PATH" "$ARFF_PATH"
