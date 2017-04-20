#!/bin/bash
set -euo pipefail

ORIGINAL_IMAGES=database/ptv-mao
SEGMENTED_IMAGES=segmentation/srm/out/
SAMPLES_PATH=tmp
CSV_PATH=segments.csv

# Generate samples for labeling
rm -rf "$SAMPLES_PATH"
mkdir "$SAMPLES_PATH"
python preparation/generate_samples.py "$ORIGINAL_IMAGES" "$SEGMENTED_IMAGES" "$SAMPLES_PATH"

# Generate initial csv file
python preparation/generate_csv_file.py "$SAMPLES_PATH" "$CSV_PATH"

# Extract attributes from images
python preparation/extract_attributes.py "$SAMPLES_PATH" "$CSV_PATH"

# Uncomment if need to label samples
# python preparation/label_samples.py "$ORIGINAL_IMAGES" "$SAMPLES_PATH" "$ARFF_PATH"
